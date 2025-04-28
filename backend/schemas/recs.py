from pydantic import BaseModel
from typing import Annotated, List
import datetime

class RecCreate(BaseModel):
    rid : int
    uid : str
    img_url: str
    content : str
    date : datetime.date
    category : str

class History

