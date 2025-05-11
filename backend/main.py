from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from sqlalchemy import func
import os 

from database import engine,get_db
from models import Base,User,Rec,History
from api import recs,histories, users,chat
from firebase.firebase_user import get_current_user
from schemas.users import (RootResponse,MemorySummary)
from models import CategoryEnum

Base.metadata.create_all(bind=engine)

app = FastAPI() # 인스턴스 생성

@app.get("/", response_model=RootResponse)
def get_root_summary(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    # 이름
    full_name = f"{user.f_name} {user.l_name}"

    # role에 따라 본인 or 보호자 Rec 조회
    target_uid = user.u_id if user.role else user.p_id

    histories = (
        db.query(History)
        .filter(History.u_id == target_uid)
        .order_by(History.date.desc())
        .limit(3)
        .all()
    )

    memories = [
        MemorySummary(file=history.rec.file, r_date=history.rec.r_date, title=history.rec.title)
        for history in histories
    ]
    
    results = (
        db.query(Rec.category, func.count(Rec.r_id))
        .filter(Rec.u_id == target_uid)
        .group_by(Rec.category)
        .all()
    )

    # 딕셔너리로 변환: Enum 기반 전체 카테고리를 기준으로 채워줌
    category_counts = {cat.value: 0 for cat in CategoryEnum}
    for category, count in results:
        category_counts[category] = count

    print(repr(os.getenv("GOOGLE_API_KEY")))
    return RootResponse(
        name=full_name,
        recent_memory=memories,
        num_rec = category_counts
    )
    
from fastapi.responses import HTMLResponse

@app.get("/ws-test", include_in_schema=False)
def websocket_test_page():
    return HTMLResponse(open("websocket.html").read())
# 라우터 등록
app.include_router(recs.router)
app.include_router(histories.router)
app.include_router(chat.router)
app.include_router(users.router)

