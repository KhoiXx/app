from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os,sys

POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
if POSTGRES_PASSWORD is None:
    sys.exit(4)
DATABASE_URL = os.getenv(
    "DATABASE_URL", f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@company.cwxb69gela3k.ap-northeast-1.rds.amazonaws.com:5432/postgres")

engine = create_engine(DATABASE_URL,isolation_level="AUTOCOMMIT")
SessionLocal = sessionmaker(autocommit=True, autoflush=False, bind=engine)

Base = declarative_base()
