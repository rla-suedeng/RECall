from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os
load_dotenv()

SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

Base = declarative_base()
# ✅ DB 엔진 생성
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, echo=True)

# ✅ 세션 클래스
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# ✅ 모델 생성용 Base 클래스
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()