# n8n 工作流说明

本目录包含用于T恤设计生成的 n8n 工作流配置文件。

## 工作流列表

### 1. tshirt-design-generator.json

**主要工作流 - 单个设计生成（保存文件版本）**

### 2. tshirt-design-generator-simple.json

**简化版工作流 - 直接返回Base64数据（推荐）**

> 💡 **推荐使用简化版**：如果遇到文件保存问题，使用此版本。它直接在响应中返回图片的 base64 数据，不依赖文件系统。

---

## 详细说明

### 1. tshirt-design-generator.json - 完整版

**功能**: 接收竞品图片，分析并生成相似设计

**触发方式**: Webhook

**输入**:
```json
{
  "imageUrl": "https://example.com/tshirt.jpg"
}
```

**节点说明**:
- `Webhook`: Webhook 触发器
- `分析图片-GPT4`: 使用 GPT-4 Vision 分析设计元素
- `生成提示词`: 将分析结果转换为 Stable Diffusion 提示词
- `生成图片-StabilityAI`: 调用 Stability AI API 生成图片
- `处理图片数据`: 解析 base64 图片数据
- `保存文件`: 使用 Node.js fs 模块保存图片到 `/data/output/`
- `返回结果`: 返回文件信息

**配置要求**:
- OpenAI API 凭证
- Stability AI API 凭证

**输出响应**:
```json
{
  "success": true,
  "message": "T恤设计生成成功",
  "data": {
    "filename": "tshirt-design-1698123456.png",
    "seed": 123456,
    "timestamp": "2025-10-23T12:00:00.000Z"
  }
}
```

**文件保存位置**: `/data/output/tshirt-design-{timestamp}.png`

**Webhook URL**: `http://localhost:5678/webhook/generate-tshirt-design`

---

### 2. tshirt-design-generator-simple.json - 简化版（推荐）

**功能**: 接收竞品图片，分析并生成相似设计，直接返回 Base64 数据

**触发方式**: Webhook

**输入**:
```json
{
  "imageUrl": "https://example.com/tshirt.jpg"
}
```

**节点说明**:
- `Webhook`: Webhook 触发器
- `分析图片-GPT4`: 使用 GPT-4 Vision 分析设计元素
- `生成提示词`: 将分析结果转换为 Stable Diffusion 提示词
- `生成图片-StabilityAI`: 调用 Stability AI API 生成图片
- `处理图片数据`: 解析图片数据，直接返回 base64
- `返回结果`: 返回包含 base64 图片数据的 JSON

**优势**:
- ✅ 不依赖文件系统，避免权限问题
- ✅ 适合在容器化环境中使用
- ✅ 可以直接在前端显示图片（data URL）
- ✅ 更简单，更少出错

**配置要求**:
- OpenAI API 凭证
- Stability AI API 凭证

**输出响应**:
```json
{
  "success": true,
  "message": "T恤设计生成成功",
  "data": {
    "filename": "tshirt-design-1698123456.png",
    "imageBase64": "iVBORw0KGgoAAAANSUhEUgAA...",
    "mimeType": "image/png",
    "seed": 123456,
    "timestamp": "2025-10-23T12:00:00.000Z"
  }
}
```

**使用返回的图片**:

在 HTML 中显示：
```html
<img src="data:image/png;base64,{imageBase64}" alt="Generated Design" />
```

保存到文件（使用 Node.js）：
```javascript
const fs = require('fs');
const buffer = Buffer.from(response.data.imageBase64, 'base64');
fs.writeFileSync('design.png', buffer);
```

保存到文件（使用 Python）：
```python
import base64
with open('design.png', 'wb') as f:
    f.write(base64.b64decode(response['data']['imageBase64']))
```

**Webhook URL**: `http://localhost:5678/webhook/generate-tshirt-design`

---

### 3. batch-design-generator.json

**批量处理工作流**

**功能**: 定时批量处理上传的竞品图片

**触发方式**: 定时任务（默认每6小时）

**工作流程**:
1. 定时触发（cron: `0 */6 * * *`）
2. 从 `data/uploads/` 读取所有图片
3. 分批处理（每批1张）
4. 调用主工作流生成设计
5. 保存结果到数据库
6. 生成汇总报告

**节点说明**:
- `定时触发`: Schedule Trigger，可修改触发频率
- `读取竞品图片`: 读取 uploads 目录中的图片文件
- `分批处理`: 控制批处理大小，避免过载
- `调用生成工作流`: HTTP 请求调用主工作流
- `检查结果`: IF 节点，判断生成是否成功
- `保存到数据库`: 保存成功记录到 PostgreSQL
- `记录失败`: 记录失败的任务
- `生成汇总报告`: 统计成功和失败数量

**配置要求**:
- PostgreSQL 凭证
- 主工作流必须已激活

**修改定时规则**:
```javascript
// 在"定时触发"节点中修改
cronExpression: "0 */6 * * *"  // 每6小时
// 其他示例：
// "0 0 * * *"   - 每天午夜
// "0 */2 * * *" - 每2小时
// "0 9 * * 1"   - 每周一上午9点
```

## 导入工作流

### 方法1: 通过 n8n UI

1. 访问 http://localhost:5678
2. 点击左上角菜单 → "Import from File"
3. 选择工作流 JSON 文件
4. 点击 "Import"

### 方法2: 通过文件系统

将工作流文件复制到 n8n 数据目录：
```bash
docker cp workflows/tshirt-design-generator.json tshirt-design-n8n:/home/node/.n8n/workflows/
```

## 配置 API 凭证

### OpenAI API

1. 进入 "Credentials" 菜单
2. 点击 "Add Credential"
3. 选择 "OpenAI API"
4. 填入 API Key
5. 点击 "Save"

### Stability AI API

1. 进入 "Credentials" 菜单
2. 点击 "Add Credential"
3. 选择 "Header Auth"
4. 配置：
   - **Name**: `Authorization`
   - **Value**: `Bearer YOUR_STABILITY_API_KEY`
5. 点击 "Save"

### PostgreSQL

1. 进入 "Credentials" 菜单
2. 点击 "Add Credential"
3. 选择 "PostgreSQL"
4. 配置：
   - **Host**: `postgres`
   - **Database**: `n8n`
   - **User**: `n8n`
   - **Password**: (从 .env 文件获取)
   - **Port**: `5432`
5. 点击 "Save"

## 激活工作流

1. 打开工作流
2. 点击右上角的 "Inactive" 开关
3. 确认工作流变为 "Active" 状态

## 测试工作流

### 测试主工作流

```bash
curl -X POST http://localhost:5678/webhook/generate-tshirt-design \
  -H "Content-Type: application/json" \
  -d '{
    "imageUrl": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab"
  }'
```

或使用测试脚本：
```bash
./scripts/test-workflow.sh
```

### 测试批量工作流

1. 将测试图片放入 `data/uploads/` 目录
2. 在 n8n UI 中打开批量工作流
3. 点击 "Execute Workflow" 手动执行
4. 查看执行结果

## 自定义工作流

### 修改生成参数

在 `生成AI提示词` 节点中：

```javascript
return [
  {
    json: {
      prompt: prompt.trim(),
      negative_prompt: negativePrompt.trim(),
      seed: Math.floor(Math.random() * 999999),
      steps: 50,        // 增加步数提高质量
      cfg_scale: 7.5,   // 调整提示词遵循度
      width: 1024,      // 修改输出尺寸
      height: 1024,
      samples: 1        // 生成多个变体
    }
  }
];
```

### 添加风格过滤

在 `分析图片特征` 和 `生成设计图片` 之间添加新节点：

```javascript
// Code 节点 - 风格过滤
const analysis = $input.first().json.analysis;
const targetStyle = "minimalist"; // 目标风格

// 根据目标风格调整提示词
let styleModifier = "";
switch(targetStyle) {
  case "minimalist":
    styleModifier = "clean, simple, minimal design";
    break;
  case "vintage":
    styleModifier = "retro, vintage, classic style";
    break;
  case "streetwear":
    styleModifier = "urban, street style, modern";
    break;
}

return [{
  json: {
    ...analysis,
    styleModifier
  }
}];
```

### 添加图片后处理

在 `处理图片数据` 之后添加新节点：

1. **调整大小**: 使用 HTTP Request 调用图片处理服务
2. **添加水印**: 使用 Code 节点或外部API
3. **格式转换**: 转换为 JPG/WebP 等格式

示例（调整大小）：
```javascript
// Code 节点 - 调整图片大小
const sharp = require('sharp');
const imageBuffer = Buffer.from($input.first().json.imageData, 'base64');

const resized = await sharp(imageBuffer)
  .resize(2048, 2048, { fit: 'inside' })
  .png({ quality: 90 })
  .toBuffer();

return [{
  json: {
    ...$input.first().json,
    imageData: resized.toString('base64')
  }
}];
```

## 故障排查

### 工作流执行失败

1. 查看执行日志
2. 检查 API 凭证是否正确
3. 确认 API 配额是否充足
4. 查看节点的错误输出

### Webhook 不响应

1. 确认工作流已激活
2. 检查 Webhook URL 是否正确
3. 查看 n8n 日志：`docker-compose logs n8n`

### 批量处理卡住

1. 检查 `data/uploads/` 目录权限
2. 确认主工作流已激活
3. 减小批处理大小
4. 查看数据库连接是否正常

## 性能优化

### 1. 并行处理

修改 `分批处理` 节点：
```javascript
batchSize: 3  // 同时处理3个
```

### 2. 缓存分析结果

添加 Redis 节点缓存 GPT-4 分析结果：

```javascript
// 生成缓存键
const cacheKey = `analysis:${crypto.createHash('md5').update(imageUrl).digest('hex')}`;

// 检查缓存
const cached = await redis.get(cacheKey);
if (cached) {
  return [{ json: JSON.parse(cached) }];
}

// 缓存结果
await redis.set(cacheKey, JSON.stringify(analysis), 'EX', 86400); // 24小时
```

### 3. 错误重试

在关键节点添加重试逻辑：

1. 点击节点
2. 进入 "Settings"
3. 启用 "Retry On Fail"
4. 配置：
   - Max Tries: 3
   - Wait Between Tries: 1000ms

## 工作流版本管理

建议使用 Git 管理工作流：

```bash
# 导出工作流
# 在 n8n UI 中：Settings → Export → Download

# 提交到 Git
git add workflows/
git commit -m "更新工作流配置"
git push
```

## 扩展阅读

- [n8n 官方文档](https://docs.n8n.io/)
- [OpenAI API 文档](https://platform.openai.com/docs)
- [Stability AI API 文档](https://platform.stability.ai/docs)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)
