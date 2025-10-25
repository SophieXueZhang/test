"""
陪伴角色相关Schemas
"""
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime


class CompanionBase(BaseModel):
    """角色基础Schema"""
    name: str = Field(..., min_length=1, max_length=50)
    relationship: str = Field(..., pattern="^(parent|spouse|friend|child|grandparent|sibling|other)$")
    gender: Optional[str] = Field(None, pattern="^(male|female|other)$")
    background_story: Optional[str] = None


class CompanionCreate(CompanionBase):
    """创建角色Schema"""
    personality: Optional[Dict[str, Any]] = Field(default_factory=dict)
    proactive_frequency: Optional[str] = Field("normal", pattern="^(low|normal|high)$")
    emotion_style: Optional[str] = Field("balanced", pattern="^(reserved|balanced|expressive)$")


class CompanionUpdate(BaseModel):
    """更新角色Schema"""
    name: Optional[str] = Field(None, min_length=1, max_length=50)
    relationship: Optional[str] = None
    background_story: Optional[str] = None
    personality: Optional[Dict[str, Any]] = None
    proactive_frequency: Optional[str] = None
    emotion_style: Optional[str] = None
    avatar_url: Optional[str] = None
    is_active: Optional[bool] = None


class CompanionResponse(CompanionBase):
    """角色响应Schema"""
    id: int
    user_id: int
    avatar_url: Optional[str] = None
    voice_id: Optional[str] = None
    voice_provider: str
    personality: Dict[str, Any]
    system_prompt: Optional[str] = None
    proactive_frequency: str
    emotion_style: str
    is_active: bool
    setup_completed: bool
    total_conversations: int
    total_messages: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class VoiceCloneRequest(BaseModel):
    """声音克隆请求Schema"""
    audio_file_url: str
    voice_name: Optional[str] = None
    description: Optional[str] = None
