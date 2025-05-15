from sqlalchemy import Column, Integer, String, Text, DateTime,Date,Boolean,ForeignKey,Enum,PrimaryKeyConstraint
from sqlalchemy.orm import relationship
from database import Base
from sqlalchemy.dialects.postgresql import UUID
from datetime import date,datetime
import uuid

import enum

class User(Base):
    __tablename__ = "users"

    u_id =Column(String(64), primary_key=True, nullable=False)
    role = Column(Boolean, default=True, nullable=False)  # True->reminder, False-> recorder
    email = Column(String(255), unique=True, nullable=False)
    f_name = Column(String(100), nullable=False)
    l_name = Column(String(100), nullable=False)
    birthday = Column(Date, nullable=False)
    p_id = Column(String(64), ForeignKey('users.u_id'), nullable=True)
    is_bot = Column(Boolean, default=False)
    
    patient = relationship("User", remote_side=[u_id],foreign_keys=[p_id])
    
    recs = relationship("Rec", back_populates="user", cascade="all, delete", foreign_keys="Rec.u_id")
    authored_recs = relationship("Rec", back_populates="author", foreign_keys="Rec.author_id")
    histories = relationship("History", back_populates="user",cascade="all, delete")
    chats = relationship("Chat", back_populates="user", cascade="all, delete")
    apply = relationship("Apply",back_populates = "users", cascade ="all,delete",foreign_keys = "Apply.u_id")
    apply_patient = relationship("Apply",back_populates = "patients", cascade ="all,delete",foreign_keys = "Apply.p_id")
    
class Apply(Base):
    __tablename__ = "apply"
    u_id = Column(String(64), ForeignKey('users.u_id'), nullable=True)
    p_id = Column(String(64), ForeignKey('users.u_id'), nullable=True)
    
    __table_args__ = (
        PrimaryKeyConstraint('u_id', 'p_id'),
    )

    users =  relationship("User",back_populates ="apply",foreign_keys=[u_id])
    patients = relationship("User", back_populates ="apply_patient",foreign_keys=[p_id])

class CategoryEnum(str, enum.Enum):
    childhood = "childhood"
    family = "family"
    travel = "travel"
    special = "special"
    etc = "etc"

class Rec(Base):
    __tablename__ = "rec"

    r_id = Column(Integer, primary_key=True,autoincrement=True)
    u_id =Column(String(64),ForeignKey('users.u_id', ondelete='CASCADE'), nullable=False)
    title = Column(String(255), nullable=False) 
    content = Column(Text, nullable=True)
    file = Column(String(255), nullable=False) 
    r_date = Column(Date, nullable=True)
    category = Column(Enum(CategoryEnum), nullable=False)
    author_id = Column(String(64), ForeignKey('users.u_id'), nullable=False)

    user = relationship("User", back_populates="recs", foreign_keys=[u_id])
    author = relationship("User", back_populates="authored_recs", foreign_keys=[author_id])
    histories = relationship("History", cascade="all, delete", back_populates="rec")


class History(Base):
    __tablename__ = "history"

    h_id = Column(Integer, primary_key=True,autoincrement=True)
    u_id =Column(String(64), ForeignKey('users.u_id'),nullable=False)
    r_id =  Column(Integer,ForeignKey('rec.r_id'), nullable=False)
    date = Column(Date,  default=date.today)
    summary =  Column(Text, nullable=True)
    
    user = relationship("User", back_populates="histories")
    rec = relationship("Rec", back_populates="histories")
    chats = relationship("Chat", cascade="all, delete", back_populates="histories")


class Chat(Base):
    __tablename__ = "chat"

    c_id = Column(Integer, primary_key=True,autoincrement=True)
    h_id = Column(Integer, ForeignKey('history.h_id'), nullable=False)
    u_id = Column(String(64),ForeignKey('users.u_id'))
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime,default=datetime.utcnow,nullable=False)
    
    histories = relationship("History", back_populates="chats")
    user = relationship("User", back_populates="chats")
