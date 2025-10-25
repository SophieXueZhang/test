"""
陪伴角色数据模型
"""
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base


class Companion(Base):
    """陪伴角色表"""

    __tablename__ = "companions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    # 基本信息
    name = Column(String(50), nullable=False)
    relationship = Column(String(20))
    avatar_url = Column(String)
    gender = Column(String(10))

    # AI配置
    voice_id = Column(String(100))
    voice_provider = Column(String(50), default="elevenlabs")

    # 性格与背景
    personality = Column(JSON, default={})
    background_story = Column(String)
    system_prompt = Column(String)

    # 行为配置
    proactive_frequency = Column(String(20), default="normal")
    emotion_style = Column(String(20), default="balanced")

    # 状态
    is_active = Column(Boolean, default=True)
    setup_completed = Column(Boolean, default=False)

    # 统计
    total_conversations = Column(Integer, default=0)
    total_messages = Column(Integer, default=0)

    # 时间戳
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime, nullable=True)

    # 关系
    # user = relationship("User", back_populates="companions")

    def __repr__(self):
        return f"<Companion {self.id}: {self.name} ({self.relationship})>"
