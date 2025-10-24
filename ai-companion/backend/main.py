"""
AI情感陪伴系统 - 后端API主程序
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 导入路由（稍后创建）
# from api import users, personas, conversations, memories

# 应用生命周期管理
@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用启动和关闭时的操作"""
    # 启动时
    print("🚀 AI情感陪伴系统启动中...")
    # 这里可以初始化数据库连接、加载模型等
    yield
    # 关闭时
    print("👋 AI情感陪伴系统关闭中...")
    # 这里可以关闭数据库连接、清理资源等

# 创建FastAPI应用
app = FastAPI(
    title="AI情感陪伴系统 API",
    description="为中老年人提供AI情感陪伴服务",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================
# 基础路由
# ============================================

@app.get("/")
async def root():
    """根路径"""
    return {
        "message": "AI情感陪伴系统 API",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """健康检查"""
    return {
        "status": "healthy",
        "service": "ai-companion-api",
        "environment": os.getenv("ENVIRONMENT", "development")
    }

# ============================================
# API路由（示例）
# ============================================

@app.post("/api/emotion-analysis")
async def analyze_emotion(data: dict):
    """
    情感分析API

    接收文本，返回情感分析结果
    """
    text = data.get("text", "")

    if not text:
        raise HTTPException(status_code=400, detail="文本不能为空")

    # 这里应该调用实际的情感分析模型
    # 暂时返回模拟数据
    return {
        "emotion": "neutral",
        "intensity": 0.5,
        "risk_score": 0.1,
        "trigger_words": []
    }

@app.post("/api/memory-search")
async def search_memories(data: dict):
    """
    记忆检索API (RAG)

    使用向量数据库检索相关记忆
    """
    user_id = data.get("user_id")
    query = data.get("query")
    top_k = data.get("top_k", 5)

    if not user_id or not query:
        raise HTTPException(status_code=400, detail="user_id和query不能为空")

    # 这里应该调用向量数据库检索
    # 暂时返回模拟数据
    return {
        "memories": [
            {
                "content": "用户喜欢早上喝豆浆",
                "relevance_score": 0.85
            },
            {
                "content": "用户的孙子叫小明",
                "relevance_score": 0.72
            }
        ]
    }

@app.post("/api/memory-create")
async def create_memory(data: dict):
    """
    创建记忆

    从对话中提取并保存重要信息
    """
    user_id = data.get("user_id")
    content = data.get("content")
    message_id = data.get("message_id")

    if not user_id or not content:
        raise HTTPException(status_code=400, detail="user_id和content不能为空")

    # 这里应该：
    # 1. 使用GPT提取重要信息
    # 2. 生成向量嵌入
    # 3. 保存到向量数据库

    return {
        "memory_id": "mock-memory-id",
        "status": "created"
    }

# ============================================
# 注册子路由
# ============================================

# app.include_router(users.router, prefix="/api/users", tags=["Users"])
# app.include_router(personas.router, prefix="/api/personas", tags=["Personas"])
# app.include_router(conversations.router, prefix="/api/conversations", tags=["Conversations"])
# app.include_router(memories.router, prefix="/api/memories", tags=["Memories"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
