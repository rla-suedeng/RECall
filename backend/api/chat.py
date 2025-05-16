from fastapi import FastAPI, HTTPException, Depends,APIRouter,Request,Body,WebSocket, WebSocketDisconnect,Form, File, UploadFile
from typing import List,Optional
from sqlalchemy.orm import Session


from database import get_db
from schemas.chat import (ChatGet)
from firebase.firebase_user import get_current_user,get_current_auth_user
from models import  User,History,Chat
from api.AI_server import stt,tts,enter_chat,send_messages
from firebase.firebase_user import AuthenticatedUser
router = APIRouter(prefix="/chat", tags=["chat"])


@router.get("/{history_id}", response_model=List[ChatGet])
def get_chat_list(
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

@router.post("/enter")
async def chatroom(
    db: Session = Depends(get_db),
    auth_user: AuthenticatedUser = Depends(get_current_auth_user)
):
    user = auth_user.user
    if not user.role:
        raise HTTPException(status_code=403, detail="You are not allowed to chat.")
    result = await enter_chat(db,auth_user)
    return result

@router.post("/{h_id}/message")
async def message(
    h_id :int,
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    auth_user: AuthenticatedUser = Depends(get_current_auth_user)    
):
    user = auth_user.user
    if not user.role:
        raise HTTPException(status_code=403, detail="You are not allowed to chat.")
    content = await file.read()
    text_output = await stt(content)
    result = await send_messages(h_id, text_output, db, auth_user)
    return result
