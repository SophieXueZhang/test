#!/bin/bash

# 备份脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}创建备份...${NC}"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 加载环境变量
source .env

# 备份数据库
echo -e "${YELLOW}备份数据库...${NC}"
docker exec tshirt-design-db pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > "$BACKUP_DIR/database.sql"

# 备份生成的图片
echo -e "${YELLOW}备份生成的图片...${NC}"
cp -r data/output "$BACKUP_DIR/output"

# 备份工作流配置
echo -e "${YELLOW}备份工作流配置...${NC}"
cp -r workflows "$BACKUP_DIR/workflows"

# 压缩备份
echo -e "${YELLOW}压缩备份...${NC}"
tar -czf "${BACKUP_DIR}.tar.gz" -C backups "$(basename $BACKUP_DIR)"
rm -rf "$BACKUP_DIR"

echo ""
echo -e "${GREEN}备份完成: ${BACKUP_DIR}.tar.gz${NC}"
echo ""
