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
    u_id: UUID
    content:str
    file: str
    date: Optional[date]
    category: CategoryEnum
    author_id: UUID

class RecCreate(RecBase):
    pass

class RecGet(RecBase):
    r_id: UUID

class RecUpdate(BaseModel):
    content: Optional[str]
    file: Optional[str]
    date: Optional[date]
    category: Optional[CategoryEnum]


class RecDelete(BaseModel):
    r_id: UUID







