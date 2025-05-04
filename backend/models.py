from sqlalchemy import Column, Integer, String, Text, DateTime,Date,Boolean,ForeignKey,Enum
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy.dialects.postgresql import UUID

import uuid

import enum

class User(Base):
    __tablename__ = "users"

    id =Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, nullable=False)
    role = Column(Boolean, nullable=False)  # True면 patient, False면 care
    email = Column(String, unique=True, nullable=False)
    f_name = Column(String, nullable=False)
    l_name = Column(String, nullable=False)
    birthday = Column(Date, nullable=False)
    p_id = Column(Integer, ForeignKey('user.id'), nullable=True)
    is_bot = Column(Boolean, default=False)
    
    patient = relationship("User", remote_side=[id])
    
    recs = relationship("Rec", back_populates="user", cascade="all, delete", foreign_keys="Rec.u_id")
    authored_recs = relationship("Rec", back_populates="author", foreign_keys="Rec.author_id")
    histories = relationship("History", back_populates="user",cascade="all, delete")
    chats = relationship("Chat", back_populates="user", cascade="all, delete") 

class CategoryEnum(str, enum.Enum):
    childhood = "childhood"
    family = "family"
    travel = "travel"
    special = "special"

class Rec(Base):
    __tablename__ = "rec"

    id = Column(Integer, primary_key=True,autoincrement=True)
    u_id =Column(UUID(as_uuid=True),ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    content = Column(Text, nullable=False)
    file = Column(String, nullable=False) 
    date = Column(Date, nullable=True)
    category = Column(Enum(CategoryEnum), nullable=False)
    author_id = Column(Integer, ForeignKey('users.id'), nullable=False)

    user = relationship("User", back_populates="recs", foreign_keys=[u_id])
    author = relationship("User", back_populates="authored_recs", foreign_keys=[author_id])
    histories = relationship("History", cascade="all, delete", back_populates="rec")
    chats = relationship("Chat", cascade="all, delete", back_populates="rec")

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True,autoincrement=True)
    u_id =Column(UUID(as_uuid=True), ForeignKey('users.id'),nullable=False)
    r_id =  Column(Integer,ForeignKey('rec.id'), nullable=False)
    date = Column(Date, nullable=True)
    
    user = relationship("User", back_populates="histories")
    rec = relationship("Rec", back_populates="histories")
    chats = relationship("Chat", cascade="all, delete", back_populates="histories")


class Chat(Base):
    __tablename__ = "chat"

    id = Column(Integer, primary_key=True,autoincrement=True)
    h_id = Column(Integer, ForeignKey('history.id'), nullable=False)
    r_id =  Column(Integer,ForeignKey('rec.id'), nullable=False)
    u_id = Column(UUID(as_uuid=True),ForeignKey('user.id'))
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, nullable=False)
    
    histories = relationship("History", back_populates="chats")
    rec = relationship("Rec", back_populates="chats")
    user = relationship("User", back_populates="chats")
    chats = relationship("Chat", back_populates="chats")