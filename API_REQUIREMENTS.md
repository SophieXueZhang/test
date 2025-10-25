# 永伴AI - API密钥需求清单

## 📋 API总览

永伴AI系统需要以下API服务。我按照**必需**和**可选**分类，帮您了解最小启动需求。

---

## ✅ 必需的API（MVP运行必须配置）

### 1. OpenAI API ⭐️ **最重要**

**用途**：
- GPT-4 对话生成（核心功能）
- 文本向量嵌入（记忆系统）
- 情感分析

**如何获取**：
```
1. 访问：https://platform.openai.com/
2. 注册账号
3. 进入 API keys：https://platform.openai.com/api-keys
4. 点击 "Create new secret key"
5. 复制密钥（格式：sk-xxxxxxxxxxxxxxxx）
```

**配置示例**：
```bash
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_EMBEDDING_MODEL=text-embedding-3-large
```

**费用**：
- GPT-4 Turbo: ~$0.01/1K tokens (输入) + $0.03/1K tokens (输出)
- 每次对话约: ¥0.1 - 0.3
- 建议充值: $10-20 起步

**必需性**: ⭐⭐⭐⭐⭐ **绝对必需**
**用于**: 智能对话、情感分析、记忆提取

---

### 2. SECRET_KEY（应用密钥）

**用途**：
- JWT token加密
- 用户会话管理
- 安全认证

**如何生成**：
```bash
# 方法1: 在线生成
# 访问：https://randomkeygen.com/
# 选择 "CodeIgniter Encryption Keys" (256-bit)

# 方法2: 命令行生成
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# 方法3: OpenSSL
openssl rand -base64 32
```

**配置示例**：
```bash
SECRET_KEY=abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

**费用**: 免费

**必需性**: ⭐⭐⭐⭐⭐ **绝对必需**
**用于**: 用户认证、安全加密

---

## 🎨 可选的API（增强功能）

### 3. Stability AI（图像生成）❌ 暂未实现

**用途**：
- 生成角色头像
- 定制角色形象
- 图片美化

**如何获取**：
```
1. 访问：https://platform.stability.ai/
2. 注册账号
3. 获取API密钥
```

**配置示例**：
```bash
STABILITY_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
STABILITY_ENGINE=stable-diffusion-xl-1024-v1-0
```

**费用**：
- $0.04 per image (1024×1024)
- 需要预充值

**必需性**: ⭐⭐ **可选**（MVP未实现）
**用于**: 角色头像生成

**当前状态**: ⚠️ 代码中已集成，但前端未使用

---

### 4. ElevenLabs（语音合成）❌ 暂未实现

**用途**：
- 将AI文字回复转为语音
- 克隆角色声音
- 语音播放功能

**如何获取**：
```
1. 访问：https://elevenlabs.io/
2. 注册账号（有免费额度）
3. Settings → API Key
```

**配置示例**：
```bash
ELEVENLABS_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ELEVENLABS_MODEL=eleven_multilingual_v2
```

**费用**：
- 免费版: 10,000 字符/月
- Starter: $5/月 (30,000 字符)
- Creator: $22/月 (100,000 字符)

**必需性**: ⭐⭐ **可选**（MVP未实现）
**用于**: 语音合成、声音克隆

**当前状态**: ⚠️ 代码中已集成，但前端未使用

---

### 5. Azure OpenAI（备选）

**用途**：
- 作为OpenAI的替代方案
- 中国大陆更稳定的访问
- 企业级SLA保障

**如何获取**：
```
1. Azure账号：https://portal.azure.com/
2. 创建 Azure OpenAI 资源
3. 获取端点和密钥
```

**配置示例**：
```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AZURE_OPENAI_DEPLOYMENT=gpt-4
```

**必需性**: ⭐ **可选**（作为OpenAI备选）
**用于**: 替代OpenAI API

---

### 6. Anthropic Claude（备选）

**用途**：
- 作为GPT-4的替代对话模型
- 可能更好的中文理解
- 不同的对话风格

**如何获取**：
```
1. 访问：https://console.anthropic.com/
2. 注册账号
3. Settings → API Keys
```

**配置示例**：
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ANTHROPIC_MODEL=claude-3-opus-20240229
```

**必需性**: ⭐ **可选**（作为OpenAI备选）
**用于**: 替代GPT-4

---

### 7. Azure Speech（备选）

**用途**：
- 作为ElevenLabs的替代
- 语音合成和识别
- 支持中文

**如何获取**：
```
1. Azure账号：https://portal.azure.com/
2. 创建 Speech 资源
3. 获取密钥和区域
```

**配置示例**：
```bash
AZURE_SPEECH_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AZURE_SPEECH_REGION=eastasia
```

**必需性**: ⭐ **可选**（作为ElevenLabs备选）
**用于**: 语音合成

---

## 📊 API需求总结

### 最小配置（MVP可运行）

```bash
# .env 文件最小配置

# 1. OpenAI API（必需）
OPENAI_API_KEY=sk-proj-your-actual-key-here

# 2. 应用密钥（必需）
SECRET_KEY=your-random-32-char-secret-key-here

# 3. 数据库密码（建议修改）
POSTGRES_PASSWORD=your_secure_password
MINIO_SECRET_KEY=your_minio_password
```

**只需这3项，系统就能运行！** ✅

---

### 完整配置（所有功能）

如果要启用所有功能：

| API | 必需性 | 当前实现 | 月费用 |
|-----|-------|---------|--------|
| **OpenAI** | ✅ 必需 | ✅ 已实现 | $10-30 |
| **SECRET_KEY** | ✅ 必需 | ✅ 已实现 | 免费 |
| Stability AI | ❌ 可选 | ⚠️ 未使用 | $5-20 |
| ElevenLabs | ❌ 可选 | ⚠️ 未使用 | $0-22 |
| Azure OpenAI | ❌ 可选 | ⚠️ 备选 | 按需 |
| Anthropic | ❌ 可选 | ⚠️ 备选 | 按需 |
| Azure Speech | ❌ 可选 | ⚠️ 备选 | 按需 |

---

## 💰 成本估算

### 最小成本（MVP）

**只使用OpenAI：**
- OpenAI充值: $10-20
- 可支持: 100-200次对话
- 适合: 开发测试、小规模试用

**月度成本（100个活跃用户）：**
- OpenAI: ~$300
- 基础设施（服务器等）: ~$50
- **总计**: ~$350/月

### 完整功能成本

**如果启用所有API：**
- OpenAI: $300
- Stability AI: $50
- ElevenLabs: $22
- 基础设施: $50
- **总计**: ~$422/月

---

## 🔑 API获取优先级

### 立即获取（现在就需要）

1. **OpenAI API Key** ⭐⭐⭐⭐⭐
   - https://platform.openai.com/api-keys
   - 必需，核心功能

2. **生成SECRET_KEY** ⭐⭐⭐⭐⭐
   - 使用上面的命令生成
   - 必需，安全认证

### 暂时不需要（等功能实现时再说）

3. Stability AI - 等需要图像生成时
4. ElevenLabs - 等需要语音功能时
5. Azure服务 - 等需要替代方案时

---

## 🚀 快速开始配置

### 步骤1：创建.env文件

```bash
cd yongban
cp .env.example .env
```

### 步骤2：最小配置

编辑`.env`，只需配置这2项：

```bash
# 1. 获取OpenAI密钥后填入
OPENAI_API_KEY=sk-proj-粘贴你的密钥

# 2. 生成随机密钥（运行下面命令）
# python3 -c "import secrets; print(secrets.token_urlsafe(32))"
SECRET_KEY=粘贴上面命令生成的结果
```

### 步骤3：启动测试

```bash
docker-compose up -d
```

访问 http://localhost:8080 就能使用了！

---

## 📝 配置检查清单

启动前确认：

- [ ] 已获取OpenAI API Key
- [ ] 已生成SECRET_KEY（至少32位）
- [ ] 已修改数据库密码（可选，但建议）
- [ ] 已修改MinIO密码（可选，但建议）
- [ ] OpenAI账户有余额（至少$5）

---

## ⚠️ 常见问题

### Q1: OpenAI API调用失败

**检查**：
```bash
# 测试API Key是否有效
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

**常见原因**：
- API Key错误或已撤销
- 账户余额不足
- API Key没有GPT-4权限
- 网络问题（中国大陆需代理）

### Q2: 没有GPT-4权限

OpenAI新账号可能没有GPT-4权限，可以：
- 等待账号升级（充值$5后通常会开通）
- 暂时使用GPT-3.5：
  ```bash
  OPENAI_MODEL=gpt-3.5-turbo
  ```

### Q3: SECRET_KEY太短

必须至少32个字符，否则JWT加密会失败。

### Q4: 成本太高怎么办？

**降低成本的方法**：
1. 使用GPT-3.5代替GPT-4（便宜10倍）
2. 减少对话上下文长度
3. 限制用户每日消息数
4. 使用Azure OpenAI（可能更便宜）

---

## 🎯 推荐配置方案

### 方案A：开发测试（最便宜）

```bash
OPENAI_API_KEY=sk-xxx  # 只用这个
OPENAI_MODEL=gpt-3.5-turbo  # 用便宜的模型
SECRET_KEY=xxx
```

**成本**: ~$5/月

### 方案B：小规模运营（推荐）

```bash
OPENAI_API_KEY=sk-xxx
OPENAI_MODEL=gpt-4-turbo-preview  # 用GPT-4
SECRET_KEY=xxx
```

**成本**: ~$50-100/月

### 方案C：完整功能（未来）

```bash
OPENAI_API_KEY=sk-xxx
STABILITY_API_KEY=sk-xxx  # 添加图像
ELEVENLABS_API_KEY=xxx    # 添加语音
SECRET_KEY=xxx
```

**成本**: ~$200-400/月

---

## 🔗 API获取链接汇总

| API | 获取地址 | 文档 |
|-----|---------|------|
| OpenAI | https://platform.openai.com/api-keys | https://platform.openai.com/docs |
| Stability AI | https://platform.stability.ai/ | https://platform.stability.ai/docs |
| ElevenLabs | https://elevenlabs.io/app/settings | https://elevenlabs.io/docs |
| Azure OpenAI | https://portal.azure.com/ | https://learn.microsoft.com/azure/ai-services/openai/ |
| Anthropic | https://console.anthropic.com/ | https://docs.anthropic.com/ |

---

**总结**：目前MVP只需要**OpenAI API**和**SECRET_KEY**，其他API都是可选的增强功能！🚀

建议先用最小配置跑起来，等后续需要再逐步添加其他API。
