#!/bin/bash

# 工作流测试脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}T恤设计生成器 - 测试脚本${NC}"
echo ""

# 加载环境变量
if [ ! -f .env ]; then
    echo -e "${RED}错误: 未找到 .env 文件${NC}"
    exit 1
fi

source .env

# 测试图片URL
TEST_IMAGE_URL=${1:-"https://images.unsplash.com/photo-1521572163474-6864f9cf17ab"}

echo -e "${YELLOW}使用测试图片: ${TEST_IMAGE_URL}${NC}"
echo ""

# 测试 Webhook
echo -e "${GREEN}测试 Webhook 端点...${NC}"

RESPONSE=$(curl -s -X POST "${WEBHOOK_URL}/webhook/generate-tshirt-design" \
  -H "Content-Type: application/json" \
  -d "{\"imageUrl\": \"${TEST_IMAGE_URL}\"}")

echo ""
echo -e "${GREEN}响应:${NC}"
echo "$RESPONSE" | jq '.'

# 检查是否成功
if echo "$RESPONSE" | jq -e '.success == true' > /dev/null; then
    echo ""
    echo -e "${GREEN}✓ 测试成功！${NC}"

    # 提取下载URL
    DOWNLOAD_URL=$(echo "$RESPONSE" | jq -r '.data.downloadUrl')
    echo -e "生成的设计: ${YELLOW}${DOWNLOAD_URL}${NC}"
else
    echo ""
    echo -e "${RED}✗ 测试失败${NC}"
    exit 1
fi

echo ""
