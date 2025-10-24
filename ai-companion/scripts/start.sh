#!/bin/bash

# AI情感陪伴系统启动脚本

set -e

echo "========================================="
echo "  AI情感陪伴系统 - 启动脚本"
echo "========================================="
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker未安装"
    echo "请先安装Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误: Docker Compose未安装"
    echo "请先安装Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# 检查.env文件
if [ ! -f .env ]; then
    echo "⚠️  警告: .env文件不存在"
    echo "正在从.env.example创建.env文件..."
    cp .env.example .env
    echo "✅ 已创建.env文件，请编辑此文件并填入你的API密钥"
    echo ""
    read -p "按Enter键继续，或Ctrl+C退出去编辑.env文件..."
fi

# 检查OpenAI API密钥
source .env
if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "sk-your-openai-api-key-here" ]; then
    echo "⚠️  警告: OpenAI API密钥未配置"
    echo "系统将启动，但AI对话功能将不可用"
    echo "请在.env文件中配置OPENAI_API_KEY"
    echo ""
    read -p "按Enter键继续..."
fi

echo "📦 正在启动Docker容器..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "🔍 检查服务状态..."
docker-compose ps

# 等待PostgreSQL就绪
echo ""
echo "⏳ 等待PostgreSQL就绪..."
until docker-compose exec -T postgres pg_isready -U ${POSTGRES_USER:-postgres} > /dev/null 2>&1; do
    echo "  等待PostgreSQL..."
    sleep 2
done
echo "✅ PostgreSQL已就绪"

# 初始化MinIO存储桶
echo ""
echo "📁 初始化MinIO存储桶..."
./scripts/init-minio.sh

echo ""
echo "========================================="
echo "  ✅ 系统启动成功！"
echo "========================================="
echo ""
echo "访问以下地址："
echo ""
echo "  🎨 n8n工作流编辑器:"
echo "     http://localhost:5678"
echo "     用户名: ${N8N_USER:-admin}"
echo "     密码: 见.env文件"
echo ""
echo "  📚 API文档:"
echo "     http://localhost:8000/docs"
echo ""
echo "  📦 MinIO控制台:"
echo "     http://localhost:9001"
echo "     用户名: ${MINIO_ROOT_USER:-minioadmin}"
echo "     密码: 见.env文件"
echo ""
echo "  🔍 Qdrant控制台:"
echo "     http://localhost:6333/dashboard"
echo ""
echo "========================================="
echo ""
echo "💡 下一步操作："
echo "  1. 访问n8n并导入工作流（workflows/*.json）"
echo "  2. 配置n8n凭证（OpenAI、PostgreSQL等）"
echo "  3. 激活工作流"
echo "  4. 测试API: curl http://localhost:8000/health"
echo ""
echo "📖 查看完整文档: README.md"
echo "❓ 遇到问题: 查看日志 docker-compose logs -f"
echo ""
