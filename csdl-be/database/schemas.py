from pydantic import BaseModel


class AccountBase(BaseModel):
    username: str


class AccountCreate(AccountBase):
    password: str


class Account(AccountBase):
    account_id: int

    class Config:
        orm_mode = True
