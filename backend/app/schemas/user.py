"""
用户相关Schemas
"""
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import datetime, date
import re


class UserBase(BaseModel):
    """用户基础Schema"""
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    nickname: Optional[str] = None
    gender: Optional[str] = Field(None, pattern="^(male|female|other)$")
    birth_date: Optional[date] = None


class UserCreate(BaseModel):
    """用户注册Schema"""
    phone: str = Field(..., min_length=11, max_length=11)
    password: str = Field(..., min_length=6, max_length=50)
    nickname: Optional[str] = Field(None, max_length=50)
    email: Optional[EmailStr] = None

    @validator("phone")
    def validate_phone(cls, v):
        if not re.match(r"^1[3-9]\d{9}$", v):
            raise ValueError("手机号格式不正确")
        return v


class UserLogin(BaseModel):
    """用户登录Schema"""
    phone: str
    password: str


class UserUpdate(BaseModel):
    """用户更新Schema"""
    nickname: Optional[str] = Field(None, max_length=50)
    email: Optional[EmailStr] = None
    gender: Optional[str] = Field(None, pattern="^(male|female|other)$")
    birth_date: Optional[date] = None
    avatar_url: Optional[str] = None


class UserResponse(UserBase):
    """用户响应Schema"""
    id: int
    avatar_url: Optional[str] = None
    subscription_type: str
    subscription_expires_at: Optional[datetime] = None
    total_conversations: int
    total_messages: int
    created_at: datetime
    last_login_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """Token响应Schema"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class PasswordChange(BaseModel):
    """修改密码Schema"""
    old_password: str
    new_password: str = Field(..., min_length=6, max_length=50)
