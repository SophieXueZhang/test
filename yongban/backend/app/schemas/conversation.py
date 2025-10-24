"""
对话相关Schemas
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class MessageBase(BaseModel):
    """消息基础Schema"""
    content: str = Field(..., min_length=1, max_length=10000)
    content_type: str = Field("text", pattern="^(text|audio|image)$")


class MessageCreate(MessageBase):
    """创建消息Schema"""
    companion_id: int
    conversation_id: Optional[int] = None  # 如果为空，创建新会话


class MessageResponse(MessageBase):
    """消息响应Schema"""
    id: int
    conversation_id: int
    role: str
    audio_url: Optional[str] = None
    audio_duration: Optional[int] = None
    emotion: Optional[str] = None
    emotion_score: Optional[float] = None
    sentiment: Optional[str] = None
    is_important: bool
    is_proactive: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ConversationCreate(BaseModel):
    """创建对话Schema"""
    companion_id: int
    title: Optional[str] = None


class ConversationResponse(BaseModel):
    """对话响应Schema"""
    id: int
    user_id: int
    companion_id: int
    title: Optional[str] = None
    summary: Optional[str] = None
    message_count: int
    started_at: datetime
    last_message_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ConversationWithMessages(ConversationResponse):
    """带消息的对话响应"""
    messages: List[MessageResponse] = []


class ChatRequest(BaseModel):
    """聊天请求Schema"""
    message: str = Field(..., min_length=1, max_length=10000)
    companion_id: int
    conversation_id: Optional[int] = None
    include_voice: bool = Field(False, description="是否生成语音")


class ChatResponse(BaseModel):
    """聊天响应Schema"""
    conversation_id: int
    user_message: MessageResponse
    assistant_message: MessageResponse
    voice_url: Optional[str] = None
