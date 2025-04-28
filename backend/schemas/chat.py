from pydantic import BaseModel
from typing import Annotated, List


class ChatMessage(BaseModel):
    sender: str  # "user" 또는 "gemini"
    text: str
    timestamp: float
    
class SendMessage(BaseModel):
    text: str

class ChatHistoryResponse(BaseModel):
    history: List[ChatMessage]