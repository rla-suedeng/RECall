from fastapi import FastAPI, HTTPException, Depends,APIRouter,Request,Body,WebSocket, WebSocketDisconnect
from typing import Annotated,List,Optional
from sqlalchemy.orm import Session
from enum import Enum
from datetime import date, datetime

from database import get_db
from schemas.chat import (HistoryBase,ChatBase,ChatGet)
from firebase.firebase_user import get_current_user,get_current_user_ws
from models import Rec, User,History,Chat
from api.AI_server.server_python.main import stt,tts,stream,chat

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

@router.post("/")
async def post_rec(
    request: Optional[str] = Body(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
    ):
    
    result = await chat(request,db,user)
    return result

@router.websocket("/voice-chat")
async def voice_chat_websocket(
    websocket: WebSocket,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user_ws)
    ):
    await websocket.accept()
    audio_bytes = await websocket.receive_bytes()
    text_output = stt(audio_bytes)
    result = await stream(text_output,db,user)
    
    return result

@router.post("/stream")
async def post_stream(
    request: Optional[str] = Body(default=None),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user_ws)
    ):
    result = await stream(request,db,user)
    return result

@router.post('/tts')
async def post_tts(
    request: Request
):
    result = await tts(request)
    return result

