from fastapi import FastAPI, Header, HTTPException, Depends,WebSocket, WebSocketDisconnect
from firebase_admin import auth, credentials
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
import firebase_admin
from database import get_db
from models import User
from sqlalchemy.orm import Session
import os 

FIREBASE_CREDENTIAL = os.getenv("FIREBASE_CREDENTIAL")
cred = credentials.Certificate(FIREBASE_CREDENTIAL)
firebase_admin.initialize_app(cred)

class AuthenticatedUser:
    def __init__(self, user, token):
        self.user = user
        self.token = token 
    
bearer_scheme = HTTPBearer(auto_error=True)

async def get_current_user(
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)
):
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get("uid")
        user = db.query(User).filter(User.u_id == uid).first()
        if uid is None or user is None:
            raise HTTPException(status_code=401, detail="Invalid User ID")
        return user
    except Exception as e:
        print(f"Firebase Authorization error: {e}")
        raise HTTPException(status_code=401, detail="Token validation failed")

async def get_current_auth_user(
    db: Session = Depends(get_db),
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme)
) -> AuthenticatedUser:
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        uid = decoded_token.get("uid")
        user = db.query(User).filter(User.u_id == uid).first()
        if uid is None or user is None:
            raise HTTPException(status_code=401, detail="Invalid User ID")
        return AuthenticatedUser(user, token)
    except Exception as e:
        print(f"Firebase Authorization error : {e}")
        raise HTTPException(status_code=401, detail="Token validation failed")   


