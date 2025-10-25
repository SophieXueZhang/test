"""
API v1 路由
"""
from fastapi import APIRouter
from app.api.v1 import auth, users, companions, conversations

api_router = APIRouter()

# 注册各模块路由
api_router.include_router(auth.router, prefix="/auth", tags=["认证"])
api_router.include_router(users.router, prefix="/users", tags=["用户"])
api_router.include_router(companions.router, prefix="/companions", tags=["陪伴角色"])
api_router.include_router(conversations.router, prefix="/conversations", tags=["对话"])
