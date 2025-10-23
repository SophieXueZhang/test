#!/bin/bash

# T恤设计生成器 - 启动脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}T恤设计生成器 启动脚本${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: 未找到 Docker，请先安装 Docker${NC}"
    exit 1
fi

# 检查 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}错误: 未找到 Docker Compose，请先安装 Docker Compose${NC}"
    exit 1
fi

# 检查 .env 文件
if [ ! -f .env ]; then
    echo -e "${YELLOW}警告: 未找到 .env 文件，正在从 .env.example 创建...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件并填入必要的 API 密钥${NC}"
    echo -e "${YELLOW}编辑完成后重新运行此脚本${NC}"
    exit 1
fi

# 检查必要的 API 密钥
source .env
if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "sk-your-openai-api-key-here" ]; then
    echo -e "${YELLOW}警告: 未配置 OpenAI API Key${NC}"
fi

if [ -z "$STABILITY_API_KEY" ] || [ "$STABILITY_API_KEY" = "sk-your-stability-api-key-here" ]; then
    echo -e "${YELLOW}警告: 未配置 Stability AI API Key${NC}"
fi

# 创建必要的目录
echo -e "${GREEN}创建目录结构...${NC}"
mkdir -p data/uploads data/output data/templates logs

# 启动服务
echo -e "${GREEN}启动 Docker 服务...${NC}"
docker-compose up -d

# 等待服务就绪
echo -e "${GREEN}等待服务启动...${NC}"
sleep 10

# 检查服务状态
echo ""
echo -e "${GREEN}检查服务状态...${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}服务已启动！${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "n8n 界面: ${GREEN}http://localhost:5678${NC}"
echo -e "MinIO 控制台: ${GREEN}http://localhost:9001${NC}"
echo -e "PostgreSQL: ${GREEN}localhost:5432${NC}"
echo ""
echo -e "默认登录凭证（请尽快修改）："
echo -e "  n8n 用户名: ${YELLOW}${N8N_USER}${NC}"
echo -e "  n8n 密码: ${YELLOW}${N8N_PASSWORD}${NC}"
echo ""
echo -e "下一步："
echo -e "  1. 访问 http://localhost:5678 登录 n8n"
echo -e "  2. 导入 workflows 目录中的工作流"
echo -e "  3. 配置 API 凭证"
echo -e "  4. 开始生成设计！"
echo ""
echo -e "查看日志: ${YELLOW}docker-compose logs -f n8n${NC}"
echo -e "停止服务: ${YELLOW}./scripts/stop.sh${NC}"
echo ""
