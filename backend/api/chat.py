from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status, Query
from typing import Annotated,List,Optional
from sqlalchemy.orm import Session
from enum import Enum
from datetime import date, datetime

from database import get_db
from schemas.chat import (HistoryBase,ChatBase)
from firebase.firebase_user import get_current_user
from models import Rec, User,History,Chat

router = APIRouter(prefix="/chat", tags=["chat"])



@router.get("/{history_id}", response_model=List[ChatBase])
def get_chat(
    history_id: int, 
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
    ):
    history = db.query(History).filter(History.h_id == history_id).first()
    if not history:
        raise HTTPException(status_code=404, detail="Chatroom not found.")
    if history.u_id != user.u_id and history.u_id != user.p_id:
        raise HTTPException(status_code=403, detail="You are not allowed to view this chat.")

    chats = db.query(Chat).filter(Chat.h_id == history_id).order_by(Chat.timestamp).all()
    return chats