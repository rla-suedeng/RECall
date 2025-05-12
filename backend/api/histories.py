from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status, Query
from typing import Annotated,List,Optional
from sqlalchemy.orm import Session
from enum import Enum
from datetime import date, datetime

from database import get_db
from schemas.chat import (HistoryBase)
from firebase.firebase_user import get_current_user
from models import History, User,Chat

router = APIRouter(prefix="/history", tags=["history"])

@router.get("/", response_model=List[HistoryBase])
def get_histories(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    target_uid = user.u_id if user.role else user.p_id
    if not target_uid:
        raise HTTPException(status_code=400, detail="유효한 사용자 또는 보호자 없음")

    histories = db.query(History).filter(History.u_id == target_uid).order_by(History.date.desc()).all()
    return histories

@router.get("/{rec_id}", response_model=List[HistoryBase])
def get_rec_histories(
    rec_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    target_uid = user.u_id if user.role else user.p_id
    if not target_uid:
        raise HTTPException(status_code=400, detail="유효한 사용자 또는 보호자 없음")

    histories = db.query(History).filter(History.r_id == rec_id,History.u_id == target_uid).order_by(History.date.desc()).all()

    return histories

