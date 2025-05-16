from pydantic import BaseModel
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

