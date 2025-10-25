"""
关怀系统数据模型
"""
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey
from sqlalchemy.sql import func

from app.core.database import Base


class CareSchedule(Base):
    """关怀计划表"""

    __tablename__ = "care_schedules"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    companion_id = Column(Integer, ForeignKey("companions.id", ondelete="CASCADE"), nullable=False)

    # 计划信息
    name = Column(String(100), nullable=False)
    schedule_type = Column(String(20))  # daily, weekly, monthly, event, custom

    # 时间配置
    time_pattern = Column(String(50))  # cron表达式或简单时间
    timezone = Column(String(50), default="Asia/Shanghai")

    # 消息模板
    message_template = Column(String)
    message_type = Column(String(20), default="greeting")

    # 状态
    is_enabled = Column(Boolean, default=True)

    # 执行统计
    total_sent = Column(Integer, default=0)
    last_sent_at = Column(DateTime, nullable=True)
    next_scheduled_at = Column(DateTime, nullable=True)

    # 时间戳
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<CareSchedule {self.id}: {self.name}>"


class CareExecution(Base):
    """关怀执行记录表"""

    __tablename__ = "care_executions"

    id = Column(Integer, primary_key=True, index=True)
    schedule_id = Column(Integer, ForeignKey("care_schedules.id", ondelete="CASCADE"), nullable=False)
    message_id = Column(Integer, ForeignKey("messages.id", ondelete="SET NULL"), nullable=True)

    # 执行信息
    status = Column(String(20))  # success, failed, skipped
    error_message = Column(String, nullable=True)

    # 时间戳
    executed_at = Column(DateTime, server_default=func.now())

    def __repr__(self):
        return f"<CareExecution {self.id}: {self.status}>"
