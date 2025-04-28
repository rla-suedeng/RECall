from sqlalchemy import Column, Integer, String, Text, DateTime,Date,Boolean,ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True)
    role = Column(Boolean, nullable=False)  # True면 patient, False면 care
    email = Column(Integer, nullable=False)
    f_name = Column(String, nullable=False)
    l_name = Column(String, nullable=False)
    birthday = Column(Date, nullable=False)
    p_id = Column(Integer, ForeignKey('user.id'))
    
    patient = relationship("User", backref="user")

class Chat(Base):
    __tablename__ = "chat"

    id = Column(Integer, primary_key=True)
    h_id = Column(Integer, nullable=False)
    r_id = Column(Integer, nullable=False)
    u_id = Column(Integer, ForeignKey('user.id'))
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, nullable=False)
    
    patient = relationship("User", remote_side=[u_id])
    recs = relationship("Rec", back_populates="user", foreign_keys="Rec.u_id")
    authored_recs = relationship("Rec", back_populates="author", foreign_keys="Rec.author_id")


class Rec(Base):
    __tablename__ = "rec"

    id = Column(Integer, primary_key=True)
    h_id = Column(Integer, nullable=False)
    r_id = Column(Integer, nullable=False)
    u_id = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, nullable=False)

class History(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True)
    u_id = Column(Integer, nullable=False)
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, nullable=False)
    
    user = relationship("User", back_populates="recs")