# 快速开始指南

5分钟搭建T恤设计自动生成工作流！

## 第一步：准备工作

### 1.1 安装 Docker

**macOS**:
```bash
brew install --cask docker
```

**Ubuntu/Debian**:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**Windows**: 下载 [Docker Desktop](https://www.docker.com/products/docker-desktop)

### 1.2 获取 API 密钥

#### OpenAI API Key (必需)
1. 访问 https://platform.openai.com/api-keys
2. 登录或注册账号
3. 点击 "Create new secret key"
4. 复制并保存 API Key（格式：`sk-...`）

#### Stability AI API Key (必需)
1. 访问 https://platform.stability.ai/
2. 注册并登录
3. 进入 Account → API Keys
4. 创建新的 API Key
5. 复制并保存（格式：`sk-...`）

## 第二步：配置项目

### 2.1 克隆项目

```bash
git clone <repository-url>
cd test
```

### 2.2 配置环境变量

```bash
# 复制配置模板
cp .env.example .env

# 编辑配置文件
nano .env  # 或使用任何文本编辑器
```

**最少需要配置以下两项**:
```bash
OPENAI_API_KEY=sk-你的OpenAI密钥
STABILITY_API_KEY=sk-你的Stability密钥
```

其他配置使用默认值即可。

## 第三步：启动服务

### 3.1 一键启动

```bash
# 使用启动脚本（推荐）
./scripts/start.sh

# 或使用 make
make start

# 或使用 docker-compose
docker-compose up -d
```

等待约30秒，服务将自动启动。

### 3.2 验证服务

访问 http://localhost:5678，你应该看到 n8n 登录页面。

默认凭证：
- 用户名: `admin`
- 密码: `change_me_please`

> ⚠️ 首次登录后请立即修改密码！

## 第四步：导入工作流

### 4.1 登录 n8n

1. 访问 http://localhost:5678
2. 输入用户名和密码登录

### 4.2 导入主工作流

1. 点击左上角的菜单图标（三条横线）
2. 选择 "Import from File"
3. 选择文件 `workflows/tshirt-design-generator.json`
4. 点击 "Import"

### 4.3 配置 API 凭证

#### 配置 OpenAI

1. 点击左侧 "Credentials" 菜单
2. 点击 "Add Credential"
3. 搜索并选择 "OpenAI API"
4. 填入你的 API Key
5. 点击 "Save"

#### 配置 Stability AI

1. 点击 "Add Credential"
2. 搜索并选择 "Header Auth"
3. 配置如下：
   - **Name**: `Authorization`
   - **Value**: `Bearer sk-你的Stability密钥`
4. 点击 "Save"

### 4.4 关联凭证到节点

1. 打开导入的工作流
2. 点击 "分析图片特征" 节点
3. 在 "Credential for OpenAI API" 下拉框中选择你刚创建的凭证
4. 点击 "生成设计图片" 节点
5. 在 "Credential for Header Auth" 下拉框中选择 Stability AI 凭证
6. 点击工作流右上角的 "Save" 保存

### 4.5 激活工作流

点击右上角的 "Inactive" 开关，使其变为 "Active"。

## 第五步：生成你的第一个设计！

### 5.1 准备测试图片

找一张T恤设计图片，可以是：
- 在线图片URL（如 Unsplash）
- 本地图片（需要转换为 base64 或上传到图床）

### 5.2 调用 API

```bash
curl -X POST http://localhost:5678/webhook/generate-tshirt-design \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab"
  }'
```

或使用提供的测试脚本：
```bash
./scripts/test-workflow.sh
```

### 5.3 查看结果

成功的响应示例：
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

生成的图片保存在 `data/output/` 目录中。

## 常见问题

### Q1: 服务启动失败

**检查 Docker 是否运行**:
```bash
docker ps
```

**查看日志**:
```bash
docker-compose logs n8n
```

### Q2: API 调用返回错误

**错误 401/403**: API 密钥配置错误
- 检查 `.env` 文件中的密钥
- 确认凭证已正确关联到节点

**错误 429**: API 配额不足
- 检查 API 账户余额
- 等待配额重置

**错误 500**: 服务内部错误
- 查看 n8n 执行日志
- 检查工作流节点配置

### Q3: 生成速度慢

正常情况下，单个设计生成需要：
- GPT-4 分析: 5-10秒
- Stable Diffusion 生成: 10-30秒
- **总计**: 约 20-40秒

如果超过1分钟，检查：
- 网络连接
- API 服务状态
- 生成参数（steps 太高）

### Q4: 图片质量不好

调整生成参数（在"生成AI提示词"节点）：
```javascript
steps: 50-100,      // 增加步数
cfg_scale: 7-15,    // 提高提示词权重
width: 1024,        // 使用更高分辨率
height: 1024
```

## 下一步

### 批量处理

1. 导入 `workflows/batch-design-generator.json`
2. 配置数据库凭证（使用 PostgreSQL）
3. 初始化数据库：`./scripts/init-database.sh`
4. 将图片放入 `data/uploads/` 目录
5. 工作流将自动每6小时处理一次

### 自定义提示词

修改 "生成AI提示词" 节点中的代码，调整生成风格：

```javascript
const prompt = `
A creative t-shirt design featuring:
Style: ${analysis.style}
Color scheme: ${analysis.colors.join(', ')}
Elements: ${analysis.elements.join(', ')}

// 添加你的风格要求
minimalist, clean, professional, modern
`;
```

### 监控和维护

```bash
# 查看服务状态
make status

# 查看日志
make logs

# 创建备份
make backup

# 查看数据库
make shell-db
```

## 技术支持

- 📖 完整文档: 查看 `README.md`
- 🔧 工作流说明: 查看 `workflows/README.md`
- 🐛 遇到问题: 查看日志或提交 Issue

## 成本估算

每生成一个设计约 $0.03-0.08：
- GPT-4 Vision: ~$0.01-0.03
- Stable Diffusion XL: ~$0.02-0.05

假设每天生成 10 个设计：
- 每月成本: 约 $9-24

## 安全提示

1. **立即修改默认密码**
2. **不要将 `.env` 文件提交到 Git**
3. **定期更新 API 密钥**
4. **定期备份数据**: `make backup`
5. **限制 n8n 访问**（生产环境使用 HTTPS 和防火墙）

---

🎉 恭喜！你已经成功搭建了T恤设计自动生成工作流！

现在开始创造独特的设计吧！
