# 快速启动指南

> 5分钟内启动AI情感陪伴系统

## 📋 前置准备

### 必需
- Docker Desktop（macOS/Windows）或 Docker + Docker Compose（Linux）
- OpenAI API密钥（[获取地址](https://platform.openai.com/api-keys)）

### 可选
- Azure Speech Services密钥（用于更好的语音服务）
- 国产大模型API密钥（讯飞星火/通义千问等）

## 🚀 5分钟快速启动

### 步骤1: 获取代码

```bash
# 克隆或下载项目
git clone <repository-url>
cd ai-companion
```

### 步骤2: 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑.env文件，至少需要配置：
# OPENAI_API_KEY=sk-your-key-here
nano .env  # 或使用你喜欢的编辑器
```

**最小配置示例：**
```bash
# .env 文件
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
N8N_PASSWORD=your_secure_password
POSTGRES_PASSWORD=your_db_password
```

### 步骤3: 启动服务

```bash
# 一键启动（推荐）
./scripts/start.sh

# 或手动启动
docker-compose up -d
```

等待1-2分钟，直到所有服务启动完成。

### 步骤4: 验证服务

打开浏览器，访问以下地址确认服务正常：

```bash
✅ API服务: http://localhost:8000/health
✅ n8n编辑器: http://localhost:5678
✅ API文档: http://localhost:8000/docs
```

### 步骤5: 导入工作流

1. 访问 http://localhost:5678
2. 使用.env中配置的用户名密码登录
3. 点击右上角"Import from File"
4. 依次导入以下文件：
   - `workflows/conversation-handler.json`
   - `workflows/proactive-care.json`
   - `workflows/persona-creation.json`

### 步骤6: 配置n8n凭证

在n8n中配置以下凭证：

#### OpenAI API
- Credentials → New → OpenAI
- API Key: 填入你的OpenAI密钥

#### PostgreSQL
- Credentials → New → Postgres
- Host: `postgres`
- Database: `ai_companion`
- User: `postgres`
- Password: 见.env中的`POSTGRES_PASSWORD`
- Port: `5432`

#### MinIO
- Credentials → New → MinIO
- Endpoint: `minio`
- Port: `9000`
- Access Key: 见.env中的`MINIO_ROOT_USER`
- Secret Key: 见.env中的`MINIO_ROOT_PASSWORD`

### 步骤7: 激活工作流

在n8n中，点击每个工作流右上角的"Activate"开关。

## 🧪 测试系统

### 测试1: 创建AI人格

```bash
curl -X POST http://localhost:5678/webhook/persona/create \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-user-123",
    "persona_type": "parent",
    "persona_name": "妈妈",
    "relationship": "母亲",
    "characteristics": {
      "温柔": 0.9,
      "唠叨": 0.6
    },
    "interests": ["做饭", "养花", "看新闻"]
  }'
```

预期响应：
```json
{
  "success": true,
  "persona_id": "uuid-here",
  "persona_name": "妈妈",
  "message": "AI人格创建成功！"
}
```

### 测试2: 发送对话消息

```bash
curl -X POST http://localhost:5678/webhook/conversation \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-user-123",
    "persona_id": "上一步返回的persona_id",
    "content": "妈妈，我今天有点累",
    "content_type": "text"
  }'
```

预期响应：
```json
{
  "message_id": "uuid-here",
  "content": "孩子，累了就要好好休息啊。有没有按时吃饭？...",
  "emotion": "tired",
  "timestamp": "2025-10-24T12:00:00Z"
}
```

### 测试3: 查看数据库

```bash
# 进入PostgreSQL容器
docker-compose exec postgres psql -U postgres -d ai_companion

# 查看创建的人格
SELECT persona_id, persona_name, persona_type FROM ai_personas;

# 查看对话记录
SELECT sender_type, content, created_at FROM messages ORDER BY created_at DESC LIMIT 5;

# 退出
\q
```

## 📱 微信小程序开发（可选）

如需开发微信小程序前端：

```bash
cd frontend

# 安装依赖
npm install

# 开发模式
npm run dev:weapp

# 使用微信开发者工具打开 dist 目录
```

## 🔧 常见问题

### Q1: n8n无法访问？
**A:** 检查Docker容器是否正常运行：
```bash
docker-compose ps
# 所有服务应该是 "Up" 状态
```

### Q2: API返回401错误？
**A:** 检查n8n凭证配置是否正确，特别是OpenAI API密钥。

### Q3: 对话没有返回？
**A:** 查看n8n工作流执行日志：
- 访问 http://localhost:5678
- 点击"Executions"查看执行历史
- 检查是否有错误

### Q4: PostgreSQL连接失败？
**A:** 等待PostgreSQL完全启动（约30秒），然后重试。

### Q5: OpenAI API调用失败？
**A:** 检查：
- API密钥是否正确
- 账户余额是否充足
- 网络连接是否正常

## 🛑 停止服务

```bash
# 停止所有服务（保留数据）
./scripts/stop.sh

# 或
docker-compose down

# 停止并删除所有数据（慎用！）
docker-compose down -v
```

## 📊 监控和日志

### 查看实时日志
```bash
# 所有服务
docker-compose logs -f

# 特定服务
docker-compose logs -f n8n
docker-compose logs -f api
docker-compose logs -f postgres
```

### 访问管理界面
- **n8n工作流**: http://localhost:5678
- **MinIO文件**: http://localhost:9001
- **Qdrant向量库**: http://localhost:6333/dashboard
- **API文档**: http://localhost:8000/docs

## 🎯 下一步

1. ✅ **自定义人格模板**：修改 `workflows/persona-creation.json`
2. ✅ **调整对话风格**：修改人格Prompt模板
3. ✅ **配置主动关怀时间**：修改 `workflows/proactive-care.json`
4. ✅ **开发小程序前端**：查看 `frontend/` 目录
5. ✅ **部署到生产环境**：查看 `docs/DEPLOYMENT.md`

## 📚 更多文档

- [完整产品设计](AI_COMPANION_DESIGN.md)
- [API文档](docs/API.md)
- [部署指南](docs/DEPLOYMENT.md)
- [故障排查](docs/TROUBLESHOOTING.md)

## 💬 获取帮助

- GitHub Issues: [提交问题]
- 文档: [查看README.md](README.md)
- 邮箱: support@ai-companion.com

---

**祝你使用愉快！如有问题，随时联系我们。** ❤️
