from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status, Query
from typing import Annotated,List,Optional
from sqlalchemy.orm import Session
from enum import Enum
from datetime import date, datetime

from database import get_db
from schemas.recs import (RecBase,RecCreate,RecDetailGet,RecUpdate,RecDelete )
from firebase.firebase_user import get_current_user
from models import Rec, User

#CurrentUser = get_user_id

router = APIRouter(prefix="/rec", tags=["Rec"])

class CategoryEnum(str, Enum):
    childhood = "childhood"
    family = "family"
    travel = "travel" 
    special = "special"
    
@router.post("/", response_model=RecDetailGet, status_code=status.HTTP_201_CREATED)
def create_rec(
    rec: RecCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):


    if user.role == True:
        db_rec = Rec(**rec.dict(), u_id=user.u_id, author_id=user.u_id)
    else : 
        db_rec = Rec(**rec.dict(), u_id=user.p_id,author_id=user.u_id)
    db.add(db_rec)
    db.commit()
    db.refresh(db_rec)
    rec_out = RecDetailGet.from_orm(db_rec)
    rec_out.author_name = f"{db_rec.author.f_name} {db_rec.author.l_name}"
    return rec_out

@router.get("/", response_model=List[RecBase])
def get_recs(
    category: Optional[CategoryEnum] = Query(None),
    keyword: Optional[str] = Query(None),
    date_from: Optional[date] = Query(None),
    date_to: Optional[date] = Query(None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):

    if user.role == True:
        recs = db.query(Rec).filter(Rec.u_id == user.u_id).all()
    else : 
        recs = db.query(Rec).filter(Rec.u_id == user.p_id).all()
    return recs

@router.get("/{rec_id}", response_model=RecDetailGet)
def get_rec(
    rec_id: int, 
    db: Session = Depends(get_db)
    ):
    rec = db.query(Rec).filter(Rec.r_id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")
    rec_out = RecDetailGet.from_orm(rec)
    rec_out.author_name = f"{rec.author.f_name} {rec.author.l_name}"
    return rec_out

@router.put("/{rec_id}", response_model=RecDetailGet)
def update_rec(
    rec_id: int,
    update_data: RecUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    rec = db.query(Rec).filter(Rec.r_id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")

    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(rec, field, value)
        
    rec.author_id = user.u_id 
    db.commit()
    db.refresh(rec)
    rec_out = RecDetailGet.from_orm(rec)
    rec_out.author_name = f"{rec.author.f_name} {rec.author.l_name}"
    return rec_out

@router.delete("/{rec_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rec(
    rec_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) 
):
    rec = db.query(Rec).filter(Rec.r_id == rec_id).first()
    if not rec:
        raise HTTPException(status_code=404, detail="Rec not found")

    db.delete(rec)
    db.commit()
    return

