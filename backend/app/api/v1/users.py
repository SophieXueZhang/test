"""
用户管理API
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, get_password_hash, verify_password
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate, PasswordChange

router = APIRouter()


@router.get("/me", response_model=dict)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    获取当前用户信息
    """
    return {
        "success": True,
        "message": "获取成功",
        "data": UserResponse.from_orm(current_user),
    }


@router.put("/me", response_model=dict)
async def update_current_user(
    user_data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    更新当前用户信息
    """
    # 更新字段
    update_data = user_data.dict(exclude_unset=True)

    # 如果更新邮箱，检查是否已存在
    if "email" in update_data and update_data["email"]:
        existing = db.query(User).filter(
            User.email == update_data["email"],
            User.id != current_user.id
        ).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="该邮箱已被使用",
            )

    # 更新用户
    for field, value in update_data.items():
        setattr(current_user, field, value)

    db.commit()
    db.refresh(current_user)

    return {
        "success": True,
        "message": "更新成功",
        "data": UserResponse.from_orm(current_user),
    }


@router.post("/me/change-password", response_model=dict)
async def change_password(
    password_data: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    修改密码
    """
    # 验证旧密码
    if not verify_password(password_data.old_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="原密码错误",
        )

    # 更新密码
    current_user.password_hash = get_password_hash(password_data.new_password)
    db.commit()

    return {
        "success": True,
        "message": "密码修改成功",
    }


@router.delete("/me", response_model=dict)
async def delete_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    删除账户（软删除）
    """
    from datetime import datetime

    current_user.deleted_at = datetime.utcnow()
    db.commit()

    return {
        "success": True,
        "message": "账户已删除",
    }


@router.get("/me/subscription", response_model=dict)
async def get_subscription_info(current_user: User = Depends(get_current_user)):
    """
    获取订阅信息
    """
    from datetime import datetime

    is_active = False
    if current_user.subscription_type != "free":
        if not current_user.subscription_expires_at or current_user.subscription_expires_at > datetime.utcnow():
            is_active = True

    return {
        "success": True,
        "message": "获取成功",
        "data": {
            "subscription_type": current_user.subscription_type,
            "expires_at": current_user.subscription_expires_at,
            "is_active": is_active,
        },
    }
