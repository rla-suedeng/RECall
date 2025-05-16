from fastapi import FastAPI, HTTPException, Depends, Header,APIRouter,status
from sqlalchemy.orm import Session
from database import get_db
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List
from models import User,Apply
from schemas.users import UserBase,UserUpdate,UserCreate,ApplyReq,ApplyBase
from firebase.firebase_user import get_current_user
from datetime import date
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

    return {"message": "success"}

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
    
    for field, value in update_data.dict(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return user

@router.post("/accept/{user_id}")
def accept_care(
    req:date,
    user_id:str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    if user.role==False:
        raise HTTPException(status_code=401, detail="Unathorization")
    
    guardian = db.query(User).filter_by(u_id=user_id, role=False).first()  
    if not guardian or guardian.birthday != req:
        raise HTTPException(status_code=403, detail="Guardian verification failed")

    apply = db.query(Apply).filter_by(u_id=user_id, p_id=user.u_id).first()
    if not apply:
        raise HTTPException(status_code=404, detail="Application not found")
    guardian.p_id = user.u_id
    remain_apply = db.query(Apply).filter_by(u_id=user_id).all()
    for apply in remain_apply:
        db.delete(apply)
    db.commit()
    return {"message": "accept"}

@router.get("/accept", response_model=List[ApplyBase])
def get_applications_by_guardian(    
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
    ):
    if user.role==False:
        raise HTTPException(status_code=401, detail="Unathorization")
    applies = db.query(Apply).filter_by(p_id=user.u_id).all()
    result = []
    for apply in applies:
        guardian = db.query(User).filter_by(u_id=apply.u_id).first()
        if guardian:
            full_name = f"{guardian.f_name} {guardian.l_name}"
            result.append(ApplyBase(u_id=guardian.u_id, u_name=full_name))

    return result

    
    
@router.post("/apply")
def apply_patient(
    req :ApplyReq,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
    ):
    if user.p_id!=None:
        raise HTTPException(status_code=400, detail="Already have a patient")
    if user.role==True:
        raise HTTPException(status_code=401, detail="Unathorization")
    db = next(get_db())
    patient = db.query(User).filter_by(email=req.email, role=True).first()  # role=True → reminder
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    existing = db.query(Apply).filter_by(u_id=user.u_id, p_id=patient.u_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already applied")

    apply = Apply(u_id=user.u_id, p_id=patient.u_id)
    db.add(apply)
    db.commit()
    db.refresh(apply)
    return {"message": "apply"}

@router.get("/apply/list", response_model=List[ApplyBase])
def get_applications_by_guardian(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    applies = db.query(Apply).filter_by(u_id=user.u_id).all()
    result = []
    print(applies)
    for apply in applies:
        patient = db.query(User).filter_by(u_id=apply.p_id).first()
        if patient:
            full_name = f"{patient.f_name} {patient.l_name}"
            result.append(ApplyBase(u_id=patient.u_id, u_name=full_name))

    return result



@router.delete("/reject/{user_id}") #apply delete, apply reject
def reject_application(
    user_id : str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    if user.role==False:
        apply = db.query(Apply).filter_by(u_id=user.u_id, p_id=user_id).first()
    else : 
        apply = db.query(Apply).filter_by(u_id=user_id, p_id=user.u_id).first()
    if not apply:
        raise HTTPException(status_code=404, detail="Apply not found")
    db.delete(apply)
    db.commit()
    return {"message": "reject"}

@router.get("/apply/patient",response_model=ApplyBase) 
def apply_accpet(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)   
):   
    if user.p_id==None:
        raise HTTPException(status_code=404, detail="Patient not found")
    else:
        full_name = f"{user.patient.f_name} {user.patient.l_name}"
    if user.role==True:
        raise HTTPException(status_code=401, detail="Unathorization")
    
    return ApplyBase(u_id=user.p_id, u_name=full_name)