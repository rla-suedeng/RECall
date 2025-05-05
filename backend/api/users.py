from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status
from sqlalchemy.orm import Session
from database import get_db
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from models import Rec, User
from schemas.users import UserCreate,UserBase,UserUpdate
from firebase.firebase_user import get_current_user
bearer_scheme = HTTPBearer(auto_error=True)

router = APIRouter()

@router.post("/register")
def register_user(
    users: UserCreate, 
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)
):
    token = credentials.credentials
    from firebase_admin import auth as firebase_auth
    try:
        decoded = firebase_auth.verify_id_token(token)
        uid = decoded["uid"]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid Firebase token")

    # DB에 이미 있는지 확인
    existing = db.query(User).filter(User.u_id == uid).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already registered")
    db_user = User(**users.dict(), u_id=uid)
    db.add(db_user)
    db.commit()

    return {"u_id":f"{uid}" }

@router.get("/user",response_model=UserBase)
def get_user(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) ):

    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
  
@router.put("/user",response_model=UserUpdate)
def update_user(
    update_data: UserUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user) ):
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    patient = db.query(User).filter(User.u_id == update_data.p_id).first()
    if not patient: 
        raise HTTPException(status_code=404, detail="Patient not found")
    elif patient.role==False:
        raise HTTPException(status_code=401, detail="Unathorization")
    
    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user