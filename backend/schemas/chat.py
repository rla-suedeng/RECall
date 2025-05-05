from pydantic import BaseModel
from typing import Annotated, List
from uuid import UUID
from datetime import date, datetime

class HistoryBase(BaseModel):
    h_id: int
    r_id: int
    date: date
    

class ChatBase(BaseModel):
    h_id: int
    u_id: str  # "user" 또는 "gemini"
    content: str
    timestamp: datetime
    
class ChatCreate(ChatBase):
    pass


class ChatHistoryResponse(BaseModel):
    history: List[ChatBase]