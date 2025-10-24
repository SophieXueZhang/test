#!/bin/bash

# AI情感陪伴系统停止脚本

set -e

echo "========================================="
echo "  AI情感陪伴系统 - 停止脚本"
echo "========================================="
echo ""

echo "🛑 正在停止所有服务..."
docker-compose down

echo ""
echo "✅ 所有服务已停止"
echo ""
echo "💡 提示："
echo "  - 数据已保存，下次启动时会恢复"
echo "  - 要删除所有数据，运行: docker-compose down -v"
echo "  - 要重新启动，运行: ./scripts/start.sh"
echo ""
