# AI情感陪伴系统

> 为中老年人打造的AI情感陪伴产品 - 用AI捏出一个"熟悉的人"

## 📖 项目简介

这是一个专为中老年人群设计的AI情感陪伴系统，通过AI技术帮助用户创造一个"熟悉的人"的虚拟陪伴，可以是：
- 已故的亲人（父母/伴侣）
- 远方的子女
- 心中的理想伴侣
- 喜爱的偶像明星
- 老朋友

系统提供24/7的情感支持，记住用户的偏好和习惯，能够进行自然的语音对话，真正做到"陪在身边"。

## 🎯 核心功能

### 1. AI人格定制
- 5种预设人格模板（亲人/子女/伴侣/偶像/朋友）
- 个性化训练（语音上传、聊天记录导入）
- 性格特征配置（温柔/幽默/严厉等）
- 语音克隆（可选）

### 2. 智能对话
- 🎤 语音对话（支持方言）
- 💬 文字聊天
- 🧠 长期记忆（RAG技术）
- ❤️ 情感识别与共情回应

### 3. 主动关怀
- 定时问候（早/中/晚）
- 重要日期提醒
- 健康关怀
- 情绪监测

### 4. 安全保障
- 情感风险预警
- 紧急联系人通知
- 隐私数据加密
- 家属监护功能

## 🏗️ 技术架构

```
前端层: 微信小程序（适老化UI）
    ↓
应用层: n8n工作流 + Node.js/Python
    ↓
AI层: OpenAI GPT-4 + Azure Speech + Qdrant向量库
    ↓
数据层: PostgreSQL + Redis + MinIO
```

### 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| 工作流引擎 | n8n | 业务流程编排 |
| 数据库 | PostgreSQL + pgvector | 用户数据 + 向量存储 |
| 缓存 | Redis | 会话缓存 |
| 对象存储 | MinIO | 音频/图片存储 |
| 向量数据库 | Qdrant | 记忆检索(RAG) |
| AI对话 | OpenAI GPT-4 | 对话生成 |
| 语音识别 | OpenAI Whisper | 语音转文字 |
| 语音合成 | OpenAI TTS / Azure | 文字转语音 |
| 前端 | Taro.js | 微信小程序 |
| 后端 | FastAPI (Python) | REST API |

## 🚀 快速开始

### 前置要求

- Docker & Docker Compose
- OpenAI API密钥
- （可选）Azure Speech Services密钥

### 安装步骤

```bash
# 1. 克隆项目
git clone <repository-url>
cd ai-companion

# 2. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入你的API密钥

# 3. 启动服务
docker-compose up -d

# 4. 等待服务启动（约1-2分钟）
docker-compose ps

# 5. 初始化MinIO存储桶
./scripts/init-minio.sh

# 6. 访问n8n工作流编辑器
# 浏览器打开 http://localhost:5678
# 用户名: admin
# 密码: 见.env文件中的N8N_PASSWORD

# 7. 导入工作流
# 在n8n界面中导入以下工作流：
# - workflows/conversation-handler.json
# - workflows/proactive-care.json
# - workflows/persona-creation.json
```

### 测试API

```bash
# 健康检查
curl http://localhost:8000/health

# 创建测试用户
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张阿姨",
    "age": 65,
    "phone": "13800138000"
  }'

# 发送测试消息
curl -X POST http://localhost:5678/webhook/conversation \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user-uuid-here",
    "persona_id": "persona-uuid-here",
    "content": "你好，今天天气真好",
    "content_type": "text"
  }'
```

## 📁 项目结构

```
ai-companion/
├── README.md                   # 项目说明
├── docker-compose.yml          # Docker服务编排
├── .env.example               # 环境变量模板
│
├── workflows/                 # n8n工作流定义
│   ├── conversation-handler.json      # 对话处理流程
│   ├── proactive-care.json           # 主动关怀流程
│   └── persona-creation.json         # 人格创建流程
│
├── database/                  # 数据库脚本
│   ├── init.sql              # 初始化脚本
│   └── migrations/           # 数据库迁移
│
├── backend/                   # Python后端
│   ├── main.py               # FastAPI主程序
│   ├── api/                  # API路由
│   ├── services/             # 业务逻辑
│   │   ├── emotion.py        # 情感分析
│   │   ├── memory.py         # 记忆管理(RAG)
│   │   └── persona.py        # 人格管理
│   ├── models/               # 数据模型
│   └── requirements.txt      # Python依赖
│
├── frontend/                  # 微信小程序
│   ├── src/
│   │   ├── pages/            # 页面
│   │   ├── components/       # 组件
│   │   └── services/         # API调用
│   └── package.json
│
├── scripts/                   # 辅助脚本
│   ├── start.sh              # 启动服务
│   ├── stop.sh               # 停止服务
│   ├── init-minio.sh         # 初始化MinIO
│   └── backup.sh             # 数据备份
│
└── docs/                      # 文档
    ├── API.md                # API文档
    ├── DEPLOYMENT.md         # 部署指南
    └── TROUBLESHOOTING.md    # 故障排查
```

## 🔧 配置说明

### OpenAI配置

在 `.env` 文件中配置：

```bash
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_TTS_VOICE=nova  # 可选: alloy, echo, fable, onyx, nova, shimmer
```

### 数据库配置

PostgreSQL已通过Docker自动配置，包含以下核心表：
- `users` - 用户信息
- `ai_personas` - AI人格配置
- `messages` - 对话消息
- `memories` - 长期记忆
- `emotion_tracking` - 情感监测
- `care_tasks` - 关怀任务

### 工作流配置

1. 访问 http://localhost:5678
2. 登录n8n（用户名/密码见.env）
3. 依次导入workflows目录下的JSON文件
4. 配置凭证（Credentials）：
   - OpenAI API
   - PostgreSQL
   - Redis
   - MinIO

## 📊 监控与运维

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务
docker-compose logs -f n8n
docker-compose logs -f api
docker-compose logs -f postgres
```

### 数据备份

```bash
# 备份PostgreSQL数据
./scripts/backup.sh

# 备份将保存到 backups/ 目录
```

### 性能监控

访问以下地址查看各服务状态：
- n8n: http://localhost:5678
- MinIO控制台: http://localhost:9001
- Qdrant控制台: http://localhost:6333/dashboard
- API文档: http://localhost:8000/docs

## 🔒 安全考虑

### 数据隐私
- 所有对话内容端到端加密
- 敏感数据（如健康信息）单独加密存储
- 定期自动清理过期数据

### 情感安全
- 实时监测高风险情绪
- 自动通知紧急联系人
- 提供心理援助热线信息

### 系统安全
- API使用JWT认证
- 限制每日使用量（防滥用）
- 定期备份数据

## 💰 成本估算

### 开发环境（单用户测试）
- 服务器: $0（本地Docker）
- OpenAI API: ~$5/月（100条对话）
- **总计**: ~$5/月

### 生产环境（100用户）
- 云服务器: $40/月（阿里云/腾讯云）
- OpenAI API: $100/月
- Azure Speech: $30/月
- 存储: $10/月
- **总计**: ~$180/月
- **单用户成本**: $1.8/月

### 规模化（1000用户）
- 云服务器: $200/月
- OpenAI API: $800/月
- Azure Speech: $200/月
- 存储: $50/月
- CDN: $50/月
- **总计**: ~$1300/月
- **单用户成本**: $1.3/月

## 📈 路线图

### Phase 1: MVP (当前)
- ✅ 基础对话功能
- ✅ 3种人格模板
- ✅ 语音识别/合成
- ✅ 简单记忆系统
- ✅ 主动关怀

### Phase 2: 增强版 (Q2 2025)
- ⏳ 定制语音克隆
- ⏳ 虚拟形象生成
- ⏳ 高级RAG记忆
- ⏳ 电话接入
- ⏳ 家属监护App

### Phase 3: 完整版 (Q3-Q4 2025)
- ⏳ 视频通话（数字人）
- ⏳ 健康管理集成
- ⏳ 社区功能
- ⏳ 情感分析报告
- ⏳ 多语言/方言支持

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 📞 联系方式

- 项目主页: [GitHub Repository]
- 问题反馈: [GitHub Issues]
- 邮箱: support@ai-companion.com

## ⚠️ 免责声明

本系统仅供情感陪伴使用，不能替代专业的医疗、心理咨询或法律建议。如遇紧急情况，请立即联系相关专业机构。

## 💖 致谢

感谢所有为老年人数字化生活做出贡献的开发者和研究者。

---

**让科技温暖人心，让陪伴不再孤单。** ❤️
