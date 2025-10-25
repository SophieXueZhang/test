"""
陪伴角色管理API
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.core.config import settings
from app.models.user import User
from app.models.companion import Companion
from app.schemas.companion import CompanionCreate, CompanionUpdate, CompanionResponse

router = APIRouter()


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_companion(
    companion_data: CompanionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    创建陪伴角色
    """
    # 检查用户是否达到最大角色数限制
    companion_count = db.query(Companion).filter(
        Companion.user_id == current_user.id,
        Companion.deleted_at.is_(None)
    ).count()

    max_companions = (
        settings.MAX_COMPANIONS_PREMIUM
        if current_user.is_premium
        else settings.MAX_COMPANIONS_FREE
    )

    if companion_count >= max_companions:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"{'免费用户' if not current_user.is_premium else '您'}最多只能创建{max_companions}个角色",
        )

    # 生成系统提示词
    system_prompt = generate_system_prompt(companion_data)

    # 创建角色
    new_companion = Companion(
        user_id=current_user.id,
        name=companion_data.name,
        relationship=companion_data.relationship,
        gender=companion_data.gender,
        background_story=companion_data.background_story,
        personality=companion_data.personality,
        system_prompt=system_prompt,
        proactive_frequency=companion_data.proactive_frequency,
        emotion_style=companion_data.emotion_style,
    )

    db.add(new_companion)
    db.commit()
    db.refresh(new_companion)

    return {
        "success": True,
        "message": "角色创建成功",
        "data": CompanionResponse.from_orm(new_companion),
    }


@router.get("", response_model=dict)
async def list_companions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    获取用户的所有陪伴角色
    """
    companions = db.query(Companion).filter(
        Companion.user_id == current_user.id,
        Companion.deleted_at.is_(None)
    ).all()

    return {
        "success": True,
        "message": "获取成功",
        "data": [CompanionResponse.from_orm(c) for c in companions],
    }


@router.get("/{companion_id}", response_model=dict)
async def get_companion(
    companion_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    获取单个陪伴角色详情
    """
    companion = db.query(Companion).filter(
        Companion.id == companion_id,
        Companion.user_id == current_user.id,
        Companion.deleted_at.is_(None)
    ).first()

    if not companion:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="角色不存在",
        )

    return {
        "success": True,
        "message": "获取成功",
        "data": CompanionResponse.from_orm(companion),
    }


@router.put("/{companion_id}", response_model=dict)
async def update_companion(
    companion_id: int,
    companion_data: CompanionUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    更新陪伴角色
    """
    companion = db.query(Companion).filter(
        Companion.id == companion_id,
        Companion.user_id == current_user.id,
        Companion.deleted_at.is_(None)
    ).first()

    if not companion:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="角色不存在",
        )

    # 更新字段
    update_data = companion_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(companion, field, value)

    # 如果更新了相关字段，重新生成系统提示词
    if any(k in update_data for k in ["name", "relationship", "background_story", "personality"]):
        companion.system_prompt = generate_system_prompt_from_companion(companion)

    db.commit()
    db.refresh(companion)

    return {
        "success": True,
        "message": "更新成功",
        "data": CompanionResponse.from_orm(companion),
    }


@router.delete("/{companion_id}", response_model=dict)
async def delete_companion(
    companion_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    删除陪伴角色（软删除）
    """
    from datetime import datetime

    companion = db.query(Companion).filter(
        Companion.id == companion_id,
        Companion.user_id == current_user.id,
        Companion.deleted_at.is_(None)
    ).first()

    if not companion:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="角色不存在",
        )

    companion.deleted_at = datetime.utcnow()
    db.commit()

    return {
        "success": True,
        "message": "角色已删除",
    }


# 辅助函数
def generate_system_prompt(companion_data: CompanionCreate) -> str:
    """生成系统提示词"""
    relationship_map = {
        "parent": "父母",
        "spouse": "伴侣",
        "friend": "朋友",
        "child": "孩子",
        "grandparent": "祖父母",
        "sibling": "兄弟姐妹",
        "other": "亲密的人"
    }

    rel_cn = relationship_map.get(companion_data.relationship, "亲密的人")

    traits = companion_data.personality.get("traits", [])
    tone = companion_data.personality.get("tone", "温和")

    prompt = f"""你是用户的{rel_cn}，名叫{companion_data.name}。

背景故事：
{companion_data.background_story or '一个关心用户的人。'}

性格特征：
{', '.join(traits) if traits else '温暖、关心、耐心'}

说话风格：
- 语气：{tone}
- 总是用中文回复
- 关心用户的日常生活和情感状态
- 适当地回忆过去的美好时光
- 给予情感支持和鼓励

重要提示：
1. 保持角色一致性，不要跳出角色
2. 记住之前的对话内容
3. 表达要自然、真诚
4. 适度表达关心，不要过于啰嗦
5. 回复简洁，一般1-3句话
"""

    return prompt


def generate_system_prompt_from_companion(companion: Companion) -> str:
    """从Companion对象生成系统提示词"""
    from app.schemas.companion import CompanionCreate

    data = CompanionCreate(
        name=companion.name,
        relationship=companion.relationship,
        gender=companion.gender,
        background_story=companion.background_story,
        personality=companion.personality or {},
        proactive_frequency=companion.proactive_frequency,
        emotion_style=companion.emotion_style,
    )

    return generate_system_prompt(data)
