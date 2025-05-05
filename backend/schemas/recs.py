from pydantic import BaseModel
from uuid import UUID
from datetime import date, datetime
from typing import Optional
from enum import Enum

class CategoryEnum(str, Enum):
    childhood = "childhood"
    family = "family"
    travel = "travel"
    special = "special"


class RecBase(BaseModel):
    r_id:int
    file: str
    
    class Config:
        from_attributes = True

class RecCreate(BaseModel):
    content:str
    file: str
    r_date: Optional[date]
    category: CategoryEnum



class RecDetailGet(RecBase):
    content:str
    date: Optional[date]
    category: CategoryEnum
    author_name : Optional[str] = None
    

class RecUpdate(BaseModel):
    content: Optional[str] = None
    file: Optional[str]= None
    r_date: Optional[date] = None
    category: Optional[CategoryEnum]= None


class RecDelete(BaseModel):
    r_id: int







