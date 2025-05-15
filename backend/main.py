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

app = FastAPI() 

def include_cors(app):

    app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", response_model=RootResponse)
def get_root_summary(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):

    full_name = f"{user.f_name} {user.l_name}"

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

    category_counts = {cat.value: 0 for cat in CategoryEnum}
    for category, count in results:
        category_counts[category] = count

    print(repr(os.getenv("GOOGLE_API_KEY")))
    return RootResponse(
        name=full_name,
        recent_memory=memories,
        num_rec = category_counts
    )
    
app.include_router(recs.router)
app.include_router(histories.router)
app.include_router(chat.router)
app.include_router(users.router)

