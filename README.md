# T恤设计自动生成工作流

基于 n8n 的智能 T恤设计生成系统，可以分析竞品图片并自动生成相似风格的新设计。

## 功能特性

- 🎨 **智能图片分析**: 使用 GPT-4 Vision 分析竞品T恤设计的风格、颜色、元素等
- 🤖 **AI设计生成**: 基于 Stable Diffusion XL 生成高质量的新设计
- 📦 **批量处理**: 支持批量上传和处理多个竞品图片
- 💾 **数据管理**: 自动保存设计历史和元数据到数据库
- 🔄 **可视化工作流**: 通过 n8n 可视化编辑和管理工作流
- 🌐 **API接口**: 提供 Webhook API 供外部系统调用

## 系统架构

```
┌─────────────┐
│  上传图片    │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  GPT-4 Vision       │
│  分析设计特征        │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  生成提示词          │
│  (Prompt Engineering)│
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Stable Diffusion   │
│  生成新设计          │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  保存图片和元数据    │
└─────────────────────┘
```

## 快速开始

### 1. 环境准备

确保已安装：
- Docker & Docker Compose
- Git

### 2. 克隆项目

```bash
git clone <repository-url>
cd test
```

### 3. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件，填入必要的 API 密钥：

```bash
# 必填项
OPENAI_API_KEY=sk-your-openai-api-key-here
STABILITY_API_KEY=sk-your-stability-api-key-here

# 可选项（如使用其他AI服务）
REPLICATE_API_KEY=r8_your-replicate-api-key-here
HUGGINGFACE_API_KEY=hf_your-huggingface-api-key-here
```

### 4. 启动服务

```bash
docker-compose up -d
```

服务启动后，可以访问：
- n8n: http://localhost:5678
- MinIO: http://localhost:9001
- PostgreSQL: localhost:5432

### 5. 导入工作流

1. 访问 http://localhost:5678
2. 使用 `.env` 中配置的用户名密码登录
3. 点击 "Import from File"
4. 依次导入以下工作流：
   - `workflows/tshirt-design-generator.json` (主工作流)
   - `workflows/batch-design-generator.json` (批量处理工作流)

### 6. 配置 API 凭证

在 n8n 中配置以下凭证：

#### OpenAI API
1. 进入 "Credentials" → "Add Credential"
2. 选择 "OpenAI API"
3. 输入你的 API Key

#### Stability AI
1. 进入 "Credentials" → "Add Credential"
2. 选择 "Header Auth"
3. 配置：
   - Name: `Authorization`
   - Value: `Bearer YOUR_STABILITY_API_KEY`

#### PostgreSQL
1. 进入 "Credentials" → "Add Credential"
2. 选择 "PostgreSQL"
3. 配置数据库连接信息（从 `.env` 文件获取）

## 使用方法

### 方法一：通过 Webhook API

```bash
# 发送竞品图片URL
curl -X POST http://localhost:5678/webhook/generate-tshirt-design \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "https://example.com/competitor-tshirt.jpg"
  }'

# 发送 Base64 编码的图片
curl -X POST http://localhost:5678/webhook/generate-tshirt-design \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  }'
```

### 方法二：批量处理

1. 将竞品图片放入 `data/uploads/` 目录
2. 工作流会自动每6小时处理一次（可修改定时规则）
3. 生成的设计保存在 `data/output/` 目录
4. 查看数据库获取完整的设计记录

### 方法三：手动执行

1. 在 n8n 界面打开工作流
2. 点击 "Execute Workflow" 按钮
3. 提供测试数据
4. 查看执行结果

## 工作流说明

### 1. T恤设计生成器 (tshirt-design-generator.json)

主要工作流程：

```
接收图片 → 分析特征 → 生成提示词 → AI生成图片 → 保存结果 → 返回URL
```

**输入参数**:
```json
{
  "imageUrl": "图片URL或Base64数据"
}
```

**输出结果**:
```json
{
  "success": true,
  "message": "T恤设计生成成功",
  "data": {
    "filename": "tshirt-design-1698123456789-0.png",
    "downloadUrl": "http://localhost:5678/files/tshirt-design-1698123456789-0.png",
    "seed": 123456,
    "timestamp": "2025-10-23T12:00:00.000Z"
  }
}
```

### 2. 批量设计生成器 (batch-design-generator.json)

自动批量处理工作流：

```
定时触发 → 读取图片 → 分批处理 → 调用主工作流 → 保存数据库 → 生成报告
```

**配置**:
- 默认每6小时执行一次
- 从 `data/uploads/` 读取图片
- 支持 jpg, jpeg, png, webp 格式
- 结果保存到 PostgreSQL 数据库

## 数据库结构

```sql
CREATE TABLE designs (
  id SERIAL PRIMARY KEY,
  original_filename VARCHAR(255),
  generated_filename VARCHAR(255),
  download_url TEXT,
  seed INTEGER,
  analysis_data JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

手动创建表：

```bash
docker exec -it tshirt-design-db psql -U n8n -d n8n
```

然后执行上述 SQL。

## 高级配置

### 调整生成参数

在 "生成AI提示词" 节点中，可以修改以下参数：

```javascript
{
  steps: 50,           // 生成步数，越高质量越好但速度越慢 (20-150)
  cfg_scale: 7.5,      // 提示词遵循度 (1-20)
  width: 1024,         // 图片宽度
  height: 1024,        // 图片高度
  samples: 1,          // 生成数量
  seed: random()       // 随机种子，固定值可重现设计
}
```

### 自定义提示词模板

修改 "生成AI提示词" 节点中的 prompt 构建逻辑：

```javascript
const prompt = `
Professional t-shirt design, ${analysis.style} style,
featuring ${analysis.elements.join(', ')},
color palette: ${analysis.colors.join(', ')},
minimalist, high quality, 4K, centered composition
`;
```

### 添加后处理步骤

可以在工作流中添加以下节点：
- 图片裁剪/调整大小
- 添加水印
- 格式转换
- 质量压缩

## API 密钥获取

### OpenAI API Key
1. 访问 https://platform.openai.com/api-keys
2. 创建新的 API Key
3. 需要 GPT-4 Vision 访问权限

### Stability AI API Key
1. 访问 https://platform.stability.ai/
2. 注册账号并创建 API Key
3. 确保有足够的积分

### 替代方案

如果不想使用付费API，可以考虑：
- **Replicate**: https://replicate.com/ (按使用量付费)
- **Hugging Face**: https://huggingface.co/ (有免费层级)
- **本地部署**: 使用 Stable Diffusion WebUI

## 故障排查

### 问题1: n8n 无法启动

```bash
# 查看日志
docker-compose logs n8n

# 检查端口占用
lsof -i :5678

# 重启服务
docker-compose restart n8n
```

### 问题2: API 调用失败

- 检查 API Key 是否正确配置
- 确认 API 账户有足够余额
- 查看 n8n 执行日志中的详细错误信息

### 问题3: 图片生成质量不佳

- 增加 `steps` 参数（推荐 50-100）
- 调整 `cfg_scale`（推荐 7-15）
- 优化提示词描述
- 使用更高分辨率（1024x1024 或更高）

### 问题4: 批量处理太慢

- 调整批处理大小
- 使用多个并行工作流
- 考虑使用队列系统（如 RabbitMQ）

## 性能优化

### 1. 使用缓存

在 Redis 中缓存分析结果：
- 相同图片不重复分析
- 缓存常用提示词模板

### 2. 并行处理

修改批量工作流，增加并行度：
```javascript
// 在分批处理节点中设置
batchSize: 5  // 同时处理5个图片
```

### 3. 使用代理

如果 API 访问慢，可以配置代理：
```yaml
# docker-compose.yml 中添加
environment:
  - HTTP_PROXY=http://your-proxy:port
  - HTTPS_PROXY=http://your-proxy:port
```

## 扩展功能

### 1. 添加风格过滤

在工作流中添加风格选择器：
- 极简风格
- 复古风格
- 街头风格
- 艺术风格

### 2. 集成电商平台

- Shopify API 集成
- WooCommerce 集成
- 自动上传到产品库

### 3. 用户界面

创建 Web 界面：
- 上传图片
- 选择风格
- 预览设计
- 下载结果

### 4. 设计变体生成

基于一个设计生成多个变体：
- 不同颜色方案
- 不同尺寸
- 不同布局

## 成本估算

基于每张图片的大致成本：

| 服务 | 成本（每次） | 说明 |
|------|-------------|------|
| GPT-4 Vision | $0.01-0.03 | 图片分析 |
| Stable Diffusion XL | $0.02-0.05 | 图片生成 |
| **总计** | **$0.03-0.08** | 每个设计 |

月度成本（假设每天生成100个设计）：
- 低端: $90/月
- 高端: $240/月

## 许可证

MIT License

## 技术支持

遇到问题？
1. 查看本文档的"故障排查"部分
2. 检查 n8n 官方文档: https://docs.n8n.io/
3. 查看各 AI 服务的文档和状态页

## 更新日志

### v1.0.0 (2025-10-23)
- 初始版本发布
- 支持单张和批量图片处理
- 集成 GPT-4 Vision 和 Stable Diffusion XL
- 提供 Docker 一键部署

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- [n8n](https://n8n.io/) - 工作流自动化平台
- [OpenAI](https://openai.com/) - GPT-4 Vision API
- [Stability AI](https://stability.ai/) - Stable Diffusion API
