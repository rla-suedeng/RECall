from fastapi import HTTPException, Depends,APIRouter
from typing import List
from sqlalchemy.orm import Session
from database import get_db
from schemas.chat import (HistoryBase)
from firebase.firebase_user import get_current_user
from models import History, User

router = APIRouter(prefix="/history", tags=["history"])

@router.get("/", response_model=List[HistoryBase])
def get_histories(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    target_uid = user.u_id if user.role else user.p_id
    if not target_uid:
        raise HTTPException(status_code=400, detail="No valid user or reminder")

    histories = histories = (
    db.query(History)
    .filter(
        History.u_id == target_uid,
        History.summary.isnot(None)
    )
    .order_by(History.date.desc())
    .all()
)
    return histories

@router.get("/{rec_id}", response_model=List[HistoryBase])
def get_rec_histories(
    rec_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    target_uid = user.u_id if user.role else user.p_id
    if not target_uid:
        raise HTTPException(status_code=400, detail="No valid user or reminder")

    histories =  (
    db.query(History)
    .filter(
        History.r_id == rec_id,
        History.u_id == target_uid,
        History.summary.isnot(None)
    )
    .order_by(History.date.desc())
    .all()
    )


    return histories
