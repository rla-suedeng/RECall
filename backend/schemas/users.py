from pydantic import BaseModel, EmailStr
from datetime import date
from typing import Optional,List,Dict
from models import CategoryEnum

class UserBase(BaseModel):
    role: bool 
    f_name: str
    l_name: str
    email: EmailStr
    birthday: date
    p_id: Optional[str] = None
    
class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    f_name: Optional[str]
    l_name: Optional[str]
    email: Optional[EmailStr]
    birthday: Optional[date]
    p_id: Optional[str]
    
class MemorySummary(BaseModel):
    file: str
    r_date: Optional[date]=None
    title: str

class ApplyReq(BaseModel):
    email : EmailStr
    
class ApplyBase(BaseModel):
    u_id :str
    u_name :str

class RootResponse(BaseModel):
    name: str
    recent_memory: List[MemorySummary]
    num_rec:Dict[CategoryEnum, int]