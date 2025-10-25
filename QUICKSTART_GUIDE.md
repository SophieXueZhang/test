# 永伴 AI - 快速预览指南

## 🚀 5分钟快速启动

### 步骤1: 配置环境变量

```bash
cd yongban
cp .env.example .env
```

编辑 `.env` 文件，**必须**填入以下两项：

```bash
# 1. OpenAI API Key（必填）
OPENAI_API_KEY=sk-your-actual-openai-key-here

# 2. 密钥（必填，至少32位）
SECRET_KEY=change-this-to-a-random-string-at-least-32-characters-long
```

### 步骤2: 启动服务

```bash
# 方式A: 使用快速启动脚本
./scripts/quickstart.sh

# 方式B: 手动启动
docker-compose up -d
```

等待约30秒，服务启动完成。

### 步骤3: 验证服务

```bash
# 检查服务状态
docker-compose ps

# 应该看到所有服务都是 "Up" 状态
```

### 步骤4: 访问界面

打开浏览器访问：

- **前端界面**: http://localhost:8080 ⭐️ (推荐，老年人友好界面)
- **API交互文档**: http://localhost:8000/docs (开发者使用)
- **健康检查**: http://localhost:8000/health

---

## 🎯 三种预览方式

### 方式1: 使用Swagger UI（最直观）

1. 访问 http://localhost:8000/docs
2. 点击 `POST /api/v1/auth/register` 展开
3. 点击 "Try it out"
4. 填入测试数据：
```json
{
  "phone": "13900139001",
  "password": "test123456",
  "nickname": "测试用户"
}
```
5. 点击 "Execute" 执行
6. 查看返回的 `access_token`
7. 点击页面顶部的 "Authorize" 按钮
8. 输入: `Bearer YOUR_ACCESS_TOKEN`
9. 现在可以测试其他需要认证的API

**推荐测试流程**:
1. 注册用户 → 2. 创建角色 → 3. 开始对话

### 方式2: 使用Python测试脚本（最完整）

```bash
# 确保已安装requests库
pip install requests

# 运行测试脚本
python scripts/test_api.py
```

选择 `1` (完整演示) 可以看到：
- ✅ 用户注册
- ✅ 创建"妈妈"角色
- ✅ 多轮对话演示
- ✅ 查看对话历史

### 方式3: 使用curl命令（最灵活）

```bash
# 1. 注册用户
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "13900139002",
    "password": "test123456",
    "nickname": "小明"
  }'

# 复制返回的 access_token

# 2. 创建陪伴角色
TOKEN="粘贴你的token"
curl -X POST http://localhost:8000/api/v1/companions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "妈妈",
    "relationship": "parent",
    "background_story": "一位慈爱的母亲，生前最爱做饭",
    "personality": {
      "traits": ["caring", "patient", "warm"],
      "tone": "gentle"
    }
  }'

# 记住返回的 companion_id

# 3. 开始对话
COMPANION_ID=1  # 替换为实际的ID
curl -X POST http://localhost:8000/api/v1/conversations/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "companion_id": '$COMPANION_ID',
    "message": "妈妈，我今天有点累"
  }'
```

---

## 📊 查看数据库内容

```bash
# 连接到PostgreSQL
docker exec -it yongban-db psql -U yongban -d yongban

# 查看用户
SELECT id, nickname, phone, subscription_type FROM users;

# 查看角色
SELECT id, name, relationship FROM companions;

# 查看消息
SELECT id, role, content FROM messages ORDER BY created_at DESC LIMIT 10;

# 退出
\q
```

---

## 🎨 查看MinIO存储

访问 http://localhost:9001

默认账号:
- 用户名: `minioadmin`
- 密码: `minioadmin`

（建议在 .env 中修改密码）

---

## 🔍 查看日志

```bash
# 查看所有服务日志
docker-compose logs

# 只查看后端日志
docker-compose logs -f backend

# 查看最近100行
docker-compose logs --tail=100 backend
```

---

## 🛑 停止服务

```bash
# 停止但保留数据
docker-compose stop

# 停止并删除容器（数据保留在volume中）
docker-compose down

# 完全清理（包括数据）
docker-compose down -v
```

---

## 💡 测试用的示例数据

数据库已预置3个测试用户：

| 手机号 | 密码 | 昵称 | 订阅类型 |
|--------|------|------|----------|
| 13800138000 | password123 | 张阿姨 | premium |
| 13800138001 | password123 | 李大爷 | free |
| 13800138002 | password123 | 王女士 | free |

可以直接用这些账号登录测试。

---

## ⚠️ 常见问题

### Q1: 端口被占用
```bash
# 检查端口占用
lsof -i :8000
lsof -i :5432

# 修改 docker-compose.yml 中的端口映射
```

### Q2: OpenAI API调用失败
- 检查 `.env` 中的 `OPENAI_API_KEY` 是否正确
- 确认OpenAI账户有余额
- 查看日志: `docker-compose logs backend`

### Q3: 数据库连接失败
```bash
# 重启数据库服务
docker-compose restart db

# 等待30秒后重启后端
docker-compose restart backend
```

---

## 🎉 预期效果展示

### 对话示例

**用户**: "妈妈，我今天有点累"

**AI回复**: "孩子，是不是工作太忙了？要注意休息啊，别太累着自己。晚上早点睡，我给你做你最爱吃的红烧肉好不好？记得多喝水，天气凉了加件衣服。"

**特点**:
- ✅ 自然的对话语气
- ✅ 符合角色设定（母亲）
- ✅ 情感共鸣
- ✅ 上下文记忆

---

## 📈 下一步

测试完成后，可以：
1. 修改角色设定，测试不同的陪伴风格
2. 尝试多轮对话，观察记忆效果
3. 查看数据库中的情感分析结果
4. 开发前端界面

祝测试愉快！🚀
