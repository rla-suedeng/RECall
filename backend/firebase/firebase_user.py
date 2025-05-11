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
cred = credentials.Certificate(FIREBASE_CREDENTIAL)  # 서비스 계정 키 파일 경로
firebase_admin.initialize_app(cred)

    
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
        if uid is None:
            raise HTTPException(status_code=401, detail="유효하지 않은 사용자 ID")
        return user
    except Exception as e:
        print(f"Firebase 인증 오류: {e}")
        raise HTTPException(status_code=401, detail="토큰 검증 실패")
    

async def get_current_user_ws(websocket: WebSocket, db: Session = Depends(get_db)) -> User:
    token = websocket.query_params.get("token")  # 예: /voice-chat?token=Bearer+xxx

    if not token or not token.startswith("Bearer "):
        await websocket.close(code=1008)
        raise WebSocketDisconnect(code=1008)

    try:
        # Firebase 토큰 검증
        from firebase_admin import auth
        decoded = auth.verify_id_token(token[7:])
        uid = decoded["uid"]
    except Exception:
        await websocket.close(code=1008)
        raise WebSocketDisconnect(code=1008)

    user = db.query(User).filter(User.u_id == uid).first()
    if not user:
        await websocket.close(code=1008)
        raise WebSocketDisconnect(code=1008)

    return user
