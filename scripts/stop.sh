#!/bin/bash

# T恤设计生成器 - 停止脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}停止所有服务...${NC}"
docker-compose down

echo ""
echo -e "${GREEN}服务已停止${NC}"
echo ""
echo -e "如需完全清理（包括数据卷）："
echo -e "  ${YELLOW}docker-compose down -v${NC}"
echo ""
