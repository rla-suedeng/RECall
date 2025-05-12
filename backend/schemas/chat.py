from pydantic import BaseModel
from typing import Annotated, List
from uuid import UUID
from datetime import date, datetime

class HistoryBase(BaseModel):
    h_id: int
    summary: str
    date: date
    

class ChatBase(BaseModel): 
    u_id: str  
    content: str
   
    
class ChatGet(ChatBase):
    timestamp: datetime


# class Message(BaseModel):

