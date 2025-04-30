from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# ✅ SQLite 예시 (PostgreSQL, MySQL 등으로 바꿀 수 있음)
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"

# ✅ DB 엔진 생성
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

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