from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status
from typing import Annotated,List
from sqlalchemy.orm import Session
from database import get_db
from uuid import UUID



from schemas.recs import (RecBase,RecCreate,RecGet,RecUpdate,RecDelete )
from api.deps import get_user_id
from models import Rec, User

#CurrentUser = get_user_id


router = APIRouter(prefix="/rec", tags=["Rec"])

@router.post("/", response_model=RecGet, status_code=status.HTTP_201_CREATED)
def create_rec(
    rec: RecCreate,
    db: Session = Depends(get_db),
    user_id: UUID = Depends(get_user_id)
):
    # 작성자 ID가 요청한 사용자와 동일한지 검증
    if rec.u_id != user_id:
        raise HTTPException(status_code=403, detail="You are not allowed to set another user as author.")
    
    db_rec = Rec(**rec.dict())
    db.add(db_rec)
    db.commit()
    db.refresh(db_rec)
    return db_rec

@router.get("/", response_model=List[RecGet])
def get_recs(
    db: Session = Depends(get_db),
    user_id: UUID = Depends(get_user_id)
):
    recs = db.query(Rec).filter(Rec.u_id == user_id).all()
    return recs

@router.get("/{rec_id}", response_model=RecGet)
def get_rec(rec_id: int, db: Session = Depends(get_db)):
    rec = db.query(Rec).filter(Rec.id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")
    return rec

@router.put("/{rec_id}", response_model=RecGet)
def update_rec(
    rec_id: int,
    update_data: RecUpdate,
    db: Session = Depends(get_db),
    user_id: UUID = Depends(get_user_id)
):
    rec = db.query(Rec).filter(Rec.id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")

    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(rec, field, value)
        
    rec.author_id = user_id  
    db.commit()
    db.refresh(rec)
    return rec

@router.delete("/{rec_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rec(
    rec_id: int,
    db: Session = Depends(get_db),
    user_id: UUID = Depends(get_user_id)
):
    rec = db.query(Rec).filter(Rec.id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")

    db.delete(rec)
    db.commit()
    return