from pydantic import BaseModel
from typing import Annotated, List
from uuid import UUID
from datetime import date, datetime

class HistoryBase(BaseModel):
    u_id: str
    r_id: int
    date: date

class HistoryCreate(HistoryBase):
    pass

class HistoryGet(HistoryBase):
    id: int


class ChatBase(BaseModel):
    h_id: int
    r_id: int
    sender: str  # "user" 또는 "gemini"
    text: str
    timestamp: datetime
    
class ChatCreate(ChatBase):
    pass


class ChatHistoryResponse(BaseModel):
    history: List[ChatBase]