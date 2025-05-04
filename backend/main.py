from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware

from database import engine
from models import Base
from api import recs  #
from api.deps import get_user_id

app = FastAPI() # 인스턴스 생성

@app.get("/") # get method로 '/'에 해당하는  생성
def root():
    return {"message": "Hello World"}

# CORS 설정 (필요 시)
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # 프로덕션에서는 도메인 제한 필요
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# 라우터 등록
app.include_router(recs.router)

@app.get("/protected")
async def protected_route(user_id: str = Depends(get_user_id)):
    return {"message": f"인증된 사용자 ID: {user_id}"}
