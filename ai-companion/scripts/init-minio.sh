#!/bin/bash

# MinIO存储桶初始化脚本

set -e

echo "📁 初始化MinIO存储桶..."

# 等待MinIO服务就绪
echo "⏳ 等待MinIO服务启动..."
until curl -s http://localhost:9000/minio/health/live > /dev/null 2>&1; do
    echo "  等待MinIO..."
    sleep 2
done

echo "✅ MinIO服务已就绪"

# 获取MinIO凭证
source .env

# 使用MinIO客户端创建存储桶
docker run --rm --network ai-companion_ai-companion-network \
    -e MC_HOST_minio="http://${MINIO_ROOT_USER:-minioadmin}:${MINIO_ROOT_PASSWORD:-minioadmin123}@minio:9000" \
    minio/mc \
    mb --ignore-existing minio/${MINIO_BUCKET_AUDIO:-ai-companion-audio}

docker run --rm --network ai-companion_ai-companion-network \
    -e MC_HOST_minio="http://${MINIO_ROOT_USER:-minioadmin}:${MINIO_ROOT_PASSWORD:-minioadmin123}@minio:9000" \
    minio/mc \
    mb --ignore-existing minio/${MINIO_BUCKET_IMAGES:-ai-companion-images}

# 设置存储桶为公开（用于临时音频文件访问）
docker run --rm --network ai-companion_ai-companion-network \
    -e MC_HOST_minio="http://${MINIO_ROOT_USER:-minioadmin}:${MINIO_ROOT_PASSWORD:-minioadmin123}@minio:9000" \
    minio/mc \
    anonymous set download minio/${MINIO_BUCKET_AUDIO:-ai-companion-audio}

echo "✅ MinIO存储桶初始化完成"
echo ""
echo "已创建存储桶："
echo "  - ${MINIO_BUCKET_AUDIO:-ai-companion-audio} (音频文件)"
echo "  - ${MINIO_BUCKET_IMAGES:-ai-companion-images} (图片文件)"
