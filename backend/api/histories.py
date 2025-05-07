from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status, Query
from typing import Annotated,List,Optional
from sqlalchemy.orm import Session
from enum import Enum
from datetime import date, datetime

from database import get_db
from schemas.chat import (HistoryBase,ChatBase)
from firebase.firebase_user import get_current_user
from models import History, User,Chat

router = APIRouter(prefix="/history", tags=["history"])

@router.get("/", response_model=List[HistoryBase])
def get_histories(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    if user.role == True:
        histories = db.query(History).filter(History.u_id == user.u_id).order_by(History.date.desc()).all()
    else : 
       histories = db.query(History).filter(History.u_id == user.p_id).order_by(History.date.desc()).all()
    return histories

@router.get("/{rec_id}", response_model=List[HistoryBase])
def get_rec_histories(
    rec_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    users = db.query(User).filter(User.u_id == user.u_id).first()
    if users.role == True:
        histories = db.query(History).filter(History.r_id == rec_id,History.u_id == user.u_id).order_by(History.date.desc()).all()
    else : 
       histories = db.query(History).filter(History.r_id == rec_id,History.u_id == user.p_id).order_by(History.date.desc()).all()
    return histories

