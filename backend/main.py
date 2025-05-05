from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer

from database import engine
from models import Base,User
from api import recs,histories, users,chat
from firebase.firebase_user import get_current_user

Base.metadata.create_all(bind=engine)

app = FastAPI() # 인스턴스 생성

@app.get("/") # get method로 '/'에 해당하는  생성
def root():
    return {"message": "Hello Recall"}

# 라우터 등록
app.include_router(recs.router)
app.include_router(histories.router)
app.include_router(chat.router)
app.include_router(users.router)

