from pydantic import BaseModel, EmailStr
from uuid import UUID
from datetime import date, datetime
from typing import Optional
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

class UserDelete(BaseModel):
    u_id: str