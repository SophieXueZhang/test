#!/bin/bash

# 数据库初始化脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}初始化数据库...${NC}"

# 加载环境变量
source .env

# 等待 PostgreSQL 就绪
echo -e "${YELLOW}等待 PostgreSQL 启动...${NC}"
sleep 5

# 创建数据库表
echo -e "${GREEN}创建数据表...${NC}"

docker exec -i tshirt-design-db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} << EOF
-- 创建设计记录表
CREATE TABLE IF NOT EXISTS designs (
    id SERIAL PRIMARY KEY,
    original_filename VARCHAR(255) NOT NULL,
    generated_filename VARCHAR(255) NOT NULL,
    download_url TEXT NOT NULL,
    seed INTEGER,
    analysis_data JSONB,
    prompt TEXT,
    negative_prompt TEXT,
    generation_params JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_designs_created_at ON designs(created_at);
CREATE INDEX IF NOT EXISTS idx_designs_original_filename ON designs(original_filename);

-- 创建设计标签表
CREATE TABLE IF NOT EXISTS design_tags (
    id SERIAL PRIMARY KEY,
    design_id INTEGER REFERENCES designs(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_design_tags_design_id ON design_tags(design_id);
CREATE INDEX IF NOT EXISTS idx_design_tags_tag ON design_tags(tag);

-- 创建批处理任务表
CREATE TABLE IF NOT EXISTS batch_jobs (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    total_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    failed_count INTEGER DEFAULT 0,
    error_log JSONB,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建视图：最近的设计
CREATE OR REPLACE VIEW recent_designs AS
SELECT
    d.id,
    d.original_filename,
    d.generated_filename,
    d.download_url,
    d.created_at,
    array_agg(dt.tag) as tags
FROM designs d
LEFT JOIN design_tags dt ON d.id = dt.design_id
GROUP BY d.id, d.original_filename, d.generated_filename, d.download_url, d.created_at
ORDER BY d.created_at DESC
LIMIT 100;

-- 创建统计视图
CREATE OR REPLACE VIEW design_statistics AS
SELECT
    COUNT(*) as total_designs,
    COUNT(DISTINCT DATE(created_at)) as active_days,
    MAX(created_at) as last_generated,
    MIN(created_at) as first_generated
FROM designs;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${POSTGRES_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${POSTGRES_USER};

EOF

echo ""
echo -e "${GREEN}数据库初始化完成！${NC}"
echo ""
echo -e "可用的表："
echo -e "  - ${YELLOW}designs${NC}: 设计记录"
echo -e "  - ${YELLOW}design_tags${NC}: 设计标签"
echo -e "  - ${YELLOW}batch_jobs${NC}: 批处理任务"
echo ""
echo -e "可用的视图："
echo -e "  - ${YELLOW}recent_designs${NC}: 最近的设计"
echo -e "  - ${YELLOW}design_statistics${NC}: 统计信息"
echo ""
echo -e "连接数据库："
echo -e "  ${YELLOW}docker exec -it tshirt-design-db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}${NC}"
echo ""
