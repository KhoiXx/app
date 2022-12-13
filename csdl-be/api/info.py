from datetime import datetime, timedelta

from fastapi import Depends, FastAPI, HTTPException, status, APIRouter
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
import hashlib
from sqlalchemy.orm import Session
from database import models
from dependencies import get_db
from dataclasses import dataclass, field
from api.login import get_current_user, User, oauth2_scheme
from api import Permission
from enum import Enum
from typing import Optional, Callable

router = APIRouter()


class User(BaseModel):
    id: int | None = None
    permission: int | None = None
    username: str | None = None


class UserInDB(User):
    hashed_password: str


class QueryItem(Enum):
    Debt = 0
    OrderCount = 1
    CustomerGroup = 2
    OrderInfo = 3
    BuyInfo = 4
    Goods = 5
    PlaceOrder = 6


class RequestForm(BaseModel):
    order_by: list[str]
    where: list[str]


class Order(BaseModel):
    goods_id: int
    amount: int


@dataclass
class InfoQuery():
    db: Session
    token: str
    query_item: QueryItem
    method: Callable = field(init=False)
    user: User = field(init=False)
    condition: Optional[str] = None

    def __post_init__(self):
        self.user = get_current_user(self.db, self.token)
        self.method = {
            QueryItem.Debt: self.getDebt,
            QueryItem.OrderCount: self.getOrdercount,
            QueryItem.CustomerGroup: self.getCustomerGroup,
            QueryItem.OrderInfo: self.getOrderInfo,
            QueryItem.BuyInfo: self.getBuyInfo,
            QueryItem.Goods: self.getGoodsInfo,
        }

    def run(self):
        if self.user is not None and self.user.permission == Permission.CUSTOMER.value:
            return self.method[self.query_item](self.condition)
        return None
    
    def run_without_permission(self):
        return self.method[self.query_item](self.condition)

    def getDebt(self, condition=None) -> str | None:
        debt_result = self.db.execute(
            f'select amount from "Company".debt natural join "Company".customer where account_id = {self.user.id}').first()
        return "{:,}".format(debt_result[0])

    def getOrdercount(self, condition=None) -> str | None:
        return self.db.execute(
            f'CALL "Company".get_order_count(null, {self.user.id})').first()[0]

    def getCustomerGroup(self, condition=None) -> str | None:
        return self.db.execute(
            f'select group_name from "Company".customer c left join "Company".customer_group cg on c.group_id  = cg.group_id where customer_id =  (select customer_id from "Company".customer natural join "Company".account where account_id = {self.user.id})').first()[0]

    def getOrderInfo(self, condition=None) -> list | None:
        query_condition = "" if condition is None else condition
        return self.db.execute(
            f'select * from "Company".get_order_table({self.user.id}) {query_condition}').all()

    def getBuyInfo(self, condition=None) -> list | None:
        query_condition = "" if condition is None else condition
        return self.db.execute(
            f'select * from "Company".get_buy_table({self.user.id}) {query_condition}').all()

    def getGoodsInfo(self, condition=None) -> list | None:
        return self.db.execute('select goods_id, "name", categories, color from "Company".goods').all()

    def placeOrder(self, data: Order) -> bool | None:
        customer_id = self.db.execute(f'select * from "Company".get_customer_id({self.user.id})').first()[0]
        if customer_id is None:
            return False
        order_id = self.db.execute(f'CALL "Company".updateorder({customer_id},{data.goods_id},{data.amount});')
        print(order_id)
        return True

@router.get("/get_debt", response_model=str | None)
async def read_debt_info(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.Debt).run()


@router.get("/order_count", response_model=str | None)
async def read_order_count(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.OrderCount).run()


@router.get("/customer/group", response_model=str | None)
async def read_customer_group(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.CustomerGroup).run()


@router.get("/customer/order_info", response_model=list | None)
async def read_customer_group(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.OrderInfo).run()


@router.get("/customer/buy_info", response_model=list | None)
async def read_customer_group(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.BuyInfo).run()

@router.get("/goods", response_model=list | None)
async def read_goods(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.Goods).run_without_permission()


@router.post("/customer/order_info_temp", response_model=list | None)
async def read_customer_group(request_it: RequestForm, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    condition = None
    order = ""
    where = ""
    if not (request_it.order_by == "" and request_it.where == ""):
        if len(request_it.order_by):
            order = "order by "
            for item in request_it.order_by:
                if "--" in item:
                    raise "Invalid request"
                else:
                    order += item + ','
            if order[-1] == ',':
                order = order[:-1]
        if len(request_it.where):
            where = "where "
            for idx, cond in enumerate(request_it.where):
                if "--" in cond:
                    raise "Invalid request"
                else:
                    if idx == 0:
                        where += cond
                    else:
                        where += " and " + cond
        condition = where + " " + order

    return InfoQuery(db, token, QueryItem.OrderInfo, condition=condition).run()

@router.post("/place_order", response_model=bool | None)
async def place_order(request_order: Order, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    return InfoQuery(db, token, QueryItem.PlaceOrder).placeOrder(request_order)