from fastapi import APIRouter
from sqlalchemy.orm import Session
from database import models
from dependencies import get_db
from fastapi import Depends

router = APIRouter()

@router.get("/ping")
async def pong():
    # some async operation could happen here
    # example: `notes = await get_all_notes()`
    return {"ping": "pong!"}

def get_user(db: Session, user_name: int = 0):
    return db.query(models.Account).filter(models.Account.username == user_name).first()

@router.get("/csdl")
async def check_db(db: Session = Depends(get_db)):
    print(get_user(db, ))
    return "Hi chi"