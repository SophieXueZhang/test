#!/bin/bash
# 永伴 快速启动脚本

set -e

echo "========================================="
echo "  永伴 AI - 快速启动脚本"
echo "========================================="
echo ""

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 检查.env文件
if [ ! -f .env ]; then
    echo "⚠️  未找到 .env 文件，正在从 .env.example 复制..."
    cp .env.example .env
    echo ""
    echo "⚠️  请编辑 .env 文件，填入必要的API密钥："
    echo "   - OPENAI_API_KEY"
    echo "   - SECRET_KEY (至少32个字符)"
    echo "   - 修改默认密码"
    echo ""
    echo "编辑完成后，再次运行此脚本"
    exit 0
fi

# 检查必要的环境变量
source .env

if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" == "sk-your-openai-api-key-here" ]; then
    echo "❌ 请在 .env 文件中设置正确的 OPENAI_API_KEY"
    exit 1
fi

if [ -z "$SECRET_KEY" ] || [ "$SECRET_KEY" == "your-secret-key-change-this-in-production-min-32-chars" ]; then
    echo "❌ 请在 .env 文件中设置正确的 SECRET_KEY（至少32个字符）"
    exit 1
fi

echo "✅ 环境配置检查通过"
echo ""

# 启动服务
echo "🚀 启动Docker服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "📊 服务状态:"
docker-compose ps

echo ""
echo "🎉 启动完成!"
echo ""
echo "访问以下地址："
echo "  - API文档:        http://localhost:8000/docs"
echo "  - 健康检查:       http://localhost:8000/health"
echo "  - MinIO控制台:    http://localhost:9001"
echo "  - Qdrant控制台:   http://localhost:6333/dashboard"
echo ""
echo "测试API："
echo "  python scripts/test_api.py"
echo ""
echo "查看日志："
echo "  docker-compose logs -f backend"
echo ""
echo "停止服务："
echo "  docker-compose down"
echo ""
