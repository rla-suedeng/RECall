from pydantic import BaseModel, EmailStr
from uuid import UUID
from datetime import date, datetime
from typing import Optional
from enum import Enum

class UserBase(BaseModel):
    role: bool 
    f_name: str
    l_name: str
    email: EmailStr
    birthday: date
    is_patient: bool
    p_id: Optional[UUID] = None

class UserCreate(UserBase):
    pass

class UserGet(UserBase):
    u_id: UUID

class UserUpdate(BaseModel):
    f_name: Optional[str]
    l_name: Optional[str]
    email: Optional[EmailStr]
    birthday: Optional[date]
    is_patient: Optional[bool] #role 바꿀 수 있는가?
    p_id: Optional[UUID]

class UserDelete(BaseModel):
    u_id: UUID