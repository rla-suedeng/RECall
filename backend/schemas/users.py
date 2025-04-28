from pydantic import BaseModel
from typing import Annotated, List

class UserInfo(BaseModel):
    uid: str

class 