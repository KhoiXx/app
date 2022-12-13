from datetime import datetime, timedelta

from fastapi import Depends, FastAPI, HTTPException, status, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
import hashlib
from sqlalchemy.orm import Session
from database import models
from dependencies import get_db
from dataclasses import dataclass,field
from api import Permission

router = APIRouter()

# to get a string like this run:
# openssl rand -hex 32
KEY = 'CSDL'
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


class Token(BaseModel):
    access_token: str
    token_type: str

class User(BaseModel):
    id: int| None = None
    permission: int|None = None
    username: str|None = None

class UserInDB(User):
    hashed_password: str


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


def get_password_hash(password):
    pass_to_hash = password + KEY
    hashed = hashlib.md5(pass_to_hash.encode())
    return hashed.hexdigest()

def verify_password(plain_password, hashed_password):
    return get_password_hash(plain_password) == hashed_password

def get_user(db: Session, username: str = "") -> models.Account|None:
    return db.query(models.Account).filter(models.Account.username == username).first()

def get_user_name(db: Session, token: str = "") -> models.Account|None:
    user = get_current_user(db, token)
    if user is not None:
        if user.permission == Permission.CUSTOMER.value:
            result = db.execute(f'select name from "Company".account natural join "Company".customer where account_id = {user.id}').first()
            return str(result[0])
        else: # company staff
            result = db.execute(f'select name from "Company".account natural join "Company".employee where account_id = {user.id}').first()
            return str(result[0])
    return ""


def authenticate_user(db: Session, username: str, plain_password: str):
    account = get_user(db, username)
    if not account:
        return False
    if not verify_password(plain_password, account.pass_):
        return False
    return account


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=30)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, KEY, algorithm=ALGORITHM)
    return encoded_jwt


def get_current_user(db:Session, token: str):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        
    except JWTError:
        raise credentials_exception
    user = get_user(db, username=username)
    if user is None:
        raise credentials_exception
    return User(id=user.account_id, permission=user.permission, username=user.username)


@router.post("/token", response_model=Token)
async def login_for_access_token(db: Session = Depends(get_db),form_data: dict = {}):
    user = authenticate_user(db, form_data.get('username'), form_data.get('password'))
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/users/me/", response_model=User)
async def read_users_me(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme) ):
    return get_current_user(db, token)


@router.get("/users/name/", response_model=str)
async def read_users_name(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme) ):
    return get_user_name(db, token)
