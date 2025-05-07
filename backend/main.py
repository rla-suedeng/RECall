from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session

from database import engine,get_db
from models import Base,User,Rec,History
from api import recs,histories, users,chat
from firebase.firebase_user import get_current_user
from schemas.users import (RootResponse,MemorySummary)

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

    return RootResponse(
        name=full_name,
        recent_memory=memories
    )
# 라우터 등록
app.include_router(recs.router)
app.include_router(histories.router)
app.include_router(chat.router)
app.include_router(users.router)

