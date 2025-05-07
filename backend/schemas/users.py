from pydantic import BaseModel, EmailStr
from uuid import UUID
from datetime import date, datetime
from typing import Optional,List
from enum import Enum

class Userinfo(BaseModel):
    u_id : str

class UserBase(BaseModel):
    role: bool 
    f_name: str
    l_name: str
    email: EmailStr
    birthday: date
    p_id: Optional[str] = None
    
class UserCreate(UserBase):
    pass

class UserGet(UserBase):
    u_id: str

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

class RootResponse(BaseModel):
    name: str
    recent_memory: List[MemorySummary]