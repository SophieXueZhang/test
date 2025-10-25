#!/bin/bash
# 永伴项目 - 推送到新仓库脚本
# 使用方法: ./DEPLOY_TO_NEW_REPO.sh

set -e

echo "=========================================="
echo "  永伴AI - 推送到新仓库"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查当前目录
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}错误: 请在 yongban 项目根目录运行此脚本${NC}"
    exit 1
fi

echo -e "${YELLOW}步骤 1/5: 检查环境${NC}"

# 检查Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}错误: 未安装 Git${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

echo ""
echo -e "${YELLOW}步骤 2/5: 创建临时目录${NC}"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
echo "临时目录: $TEMP_DIR"

# 复制文件
echo "正在复制文件..."
cp -r * "$TEMP_DIR/" 2>/dev/null || true
cp .gitignore "$TEMP_DIR/" 2>/dev/null || true
cp .env.example "$TEMP_DIR/" 2>/dev/null || true

cd "$TEMP_DIR"
echo -e "${GREEN}✓ 文件复制完成${NC}"

echo ""
echo -e "${YELLOW}步骤 3/5: 初始化 Git 仓库${NC}"

# 初始化Git
git init
git branch -m main
git config commit.gpgsign false

echo -e "${GREEN}✓ Git 仓库初始化完成${NC}"

echo ""
echo -e "${YELLOW}步骤 4/5: 创建提交${NC}"

# 添加所有文件
git add .

# 创建提交
git commit -m "初始化永伴AI情感陪伴系统

## 项目简介
永伴是一款专注于中老年群体的AI情感陪伴产品

## 核心功能
- ✅ 用户认证系统（JWT）
- ✅ 陪伴角色管理
- ✅ GPT-4智能对话
- ✅ 长期记忆系统
- ✅ 老年人友好界面（超大字体、大按钮）

## 技术栈
- 后端: FastAPI + Python 3.11
- 数据库: PostgreSQL + Redis + Qdrant
- 前端: 原生HTML/CSS/JavaScript
- 部署: Docker Compose

## 快速开始
\`\`\`bash
cp .env.example .env
# 编辑.env，填入OPENAI_API_KEY
docker-compose up -d
# 访问 http://localhost:8080
\`\`\`

详见 README.md
"

echo -e "${GREEN}✓ 提交创建完成${NC}"

echo ""
echo -e "${YELLOW}步骤 5/5: 推送到 GitHub${NC}"

# 新仓库URL
NEW_REPO="https://github.com/SophieXueZhang/elderly_motional_support.git"

echo "目标仓库: $NEW_REPO"
echo ""

# 添加远程仓库
git remote add origin "$NEW_REPO"

# 推送
echo "正在推送..."
echo ""
echo -e "${YELLOW}注意: 如果需要认证，请输入您的 GitHub 用户名和 Personal Access Token${NC}"
echo ""

if git push -u origin main; then
    echo ""
    echo -e "${GREEN}=========================================="
    echo -e "  🎉 推送成功！"
    echo -e "==========================================${NC}"
    echo ""
    echo "项目已推送到:"
    echo "  $NEW_REPO"
    echo ""
    echo "下一步:"
    echo "  1. 访问 https://github.com/SophieXueZhang/elderly_motional_support"
    echo "  2. 验证所有文件是否完整"
    echo "  3. 设置仓库描述和Topics"
    echo ""
    echo "测试部署:"
    echo "  git clone $NEW_REPO"
    echo "  cd elderly_motional_support"
    echo "  cp .env.example .env"
    echo "  # 编辑.env，填入OPENAI_API_KEY"
    echo "  docker-compose up -d"
    echo "  # 访问 http://localhost:8080"
    echo ""
else
    echo ""
    echo -e "${RED}=========================================="
    echo -e "  ❌ 推送失败"
    echo -e "==========================================${NC}"
    echo ""
    echo "可能的原因:"
    echo "  1. 认证失败 - 需要 Personal Access Token"
    echo "  2. 仓库不存在或无权限"
    echo "  3. 网络问题"
    echo ""
    echo "获取 Personal Access Token:"
    echo "  1. 访问 https://github.com/settings/tokens"
    echo "  2. Generate new token (classic)"
    echo "  3. 选择 'repo' 权限"
    echo "  4. 推送时用 token 作为密码"
    echo ""
    echo "手动推送:"
    echo "  cd $TEMP_DIR"
    echo "  git push -u origin main"
    echo ""
    exit 1
fi

# 清理
echo "清理临时文件..."
# cd /
# rm -rf "$TEMP_DIR"

echo -e "${GREEN}✓ 完成！${NC}"
