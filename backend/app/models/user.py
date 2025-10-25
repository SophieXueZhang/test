"""
用户数据模型
"""
from sqlalchemy import Column, Integer, String, DateTime, Date, Boolean
from sqlalchemy.sql import func
from datetime import datetime

from app.core.database import Base


class User(Base):
    """用户表"""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    nickname = Column(String(50))
    avatar_url = Column(String)
    birth_date = Column(Date)
    gender = Column(String(10))

    # 订阅信息
    subscription_type = Column(String(20), default="free")
    subscription_expires_at = Column(DateTime, nullable=True)

    # 统计信息
    total_conversations = Column(Integer, default=0)
    total_messages = Column(Integer, default=0)

    # 时间戳
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    last_login_at = Column(DateTime, nullable=True)
    deleted_at = Column(DateTime, nullable=True)

    def __repr__(self):
        return f"<User {self.id}: {self.nickname or self.phone}>"

    @property
    def is_premium(self) -> bool:
        """是否为付费用户"""
        if self.subscription_type == "free":
            return False
        if self.subscription_expires_at and self.subscription_expires_at < datetime.utcnow():
            return False
        return True
