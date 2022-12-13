from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware 

from api import check_live, login, info
from database.db import SessionLocal, engine
from dependencies import get_db
from database import models

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:8080",
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
     allow_methods=["DELETE", "GET", "POST", "PUT"],
    allow_headers=["*"],
)


app.include_router(check_live.router)
app.include_router(login.router)
app.include_router(info.router)
# app.include_router(notes.router, prefix="/notes", tags=["notes"])
