-- 永伴 AI情感陪伴系统 - 数据库Schema
-- PostgreSQL 15+

-- 创建扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- 用于文本搜索

-- ============================================================================
-- 用户相关表
-- ============================================================================

-- 用户表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(50),
    avatar_url TEXT,
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),

    -- 订阅信息
    subscription_type VARCHAR(20) DEFAULT 'free' CHECK (subscription_type IN ('free', 'premium', 'vip')),
    subscription_expires_at TIMESTAMP,

    -- 统计信息
    total_conversations INTEGER DEFAULT 0,
    total_messages INTEGER DEFAULT 0,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP -- 软删除
);

-- 用户索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_subscription ON users(subscription_type, subscription_expires_at);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- 陪伴角色相关表
-- ============================================================================

-- 陪伴角色表
CREATE TABLE companions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- 基本信息
    name VARCHAR(50) NOT NULL,
    relationship VARCHAR(20) CHECK (relationship IN ('parent', 'spouse', 'friend', 'child', 'grandparent', 'sibling', 'other')),
    avatar_url TEXT,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),

    -- AI配置
    voice_id VARCHAR(100), -- TTS服务的voice ID
    voice_provider VARCHAR(50) DEFAULT 'elevenlabs', -- elevenlabs, azure, xunfei

    -- 性格与背景
    personality JSONB DEFAULT '{}', -- {"traits": ["caring", "patient"], "tone": "warm"}
    background_story TEXT, -- 角色背景故事
    system_prompt TEXT, -- AI系统提示词

    -- 行为配置
    proactive_frequency VARCHAR(20) DEFAULT 'normal' CHECK (proactive_frequency IN ('low', 'normal', 'high')),
    emotion_style VARCHAR(20) DEFAULT 'balanced' CHECK (emotion_style IN ('reserved', 'balanced', 'expressive')),

    -- 状态
    is_active BOOLEAN DEFAULT true,
    setup_completed BOOLEAN DEFAULT false, -- 是否完成初始设置

    -- 统计
    total_conversations INTEGER DEFAULT 0,
    total_messages INTEGER DEFAULT 0,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- 角色索引
CREATE INDEX idx_companions_user_id ON companions(user_id);
CREATE INDEX idx_companions_active ON companions(is_active);

-- ============================================================================
-- 对话相关表
-- ============================================================================

-- 对话会话表
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    companion_id INTEGER NOT NULL REFERENCES companions(id) ON DELETE CASCADE,

    -- 会话信息
    title VARCHAR(100),
    summary TEXT, -- 会话摘要

    -- 统计
    message_count INTEGER DEFAULT 0,

    -- 时间戳
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_message_at TIMESTAMP,
    ended_at TIMESTAMP,

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

-- 对话索引
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_companion_id ON conversations(companion_id);
CREATE INDEX idx_conversations_last_message ON conversations(last_message_at DESC);

-- 消息表
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,

    -- 消息内容
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    content_type VARCHAR(20) DEFAULT 'text' CHECK (content_type IN ('text', 'audio', 'image')),

    -- 媒体资源
    audio_url TEXT,
    audio_duration INTEGER, -- 秒

    -- 情感分析
    emotion VARCHAR(20), -- happy, sad, neutral, anxious, angry, etc.
    emotion_score FLOAT CHECK (emotion_score >= 0 AND emotion_score <= 1),
    sentiment VARCHAR(20) CHECK (sentiment IN ('positive', 'negative', 'neutral')),

    -- AI生成信息
    model_used VARCHAR(50), -- gpt-4, claude-3, etc.
    tokens_used INTEGER,

    -- 标记
    is_important BOOLEAN DEFAULT false,
    is_proactive BOOLEAN DEFAULT false, -- 是否为主动发起

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

-- 消息索引
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_important ON messages(is_important) WHERE is_important = true;

-- ============================================================================
-- 记忆系统相关表
-- ============================================================================

-- 长期记忆表
CREATE TABLE memories (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    companion_id INTEGER NOT NULL REFERENCES companions(id) ON DELETE CASCADE,

    -- 记忆内容
    memory_type VARCHAR(20) CHECK (memory_type IN ('fact', 'event', 'preference', 'relationship', 'habit')),
    content TEXT NOT NULL,

    -- 重要性与频率
    importance_score FLOAT DEFAULT 0.5 CHECK (importance_score >= 0 AND importance_score <= 1),
    access_count INTEGER DEFAULT 0, -- 被访问次数

    -- 向量化
    embedding_id VARCHAR(100), -- 向量数据库中的ID (Qdrant)

    -- 来源
    source_message_id INTEGER REFERENCES messages(id) ON DELETE SET NULL,
    source_type VARCHAR(20) DEFAULT 'conversation', -- conversation, manual, imported

    -- 时间信息
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP,
    expires_at TIMESTAMP, -- 记忆过期时间（可选）

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

-- 记忆索引
CREATE INDEX idx_memories_user_companion ON memories(user_id, companion_id);
CREATE INDEX idx_memories_type ON memories(memory_type);
CREATE INDEX idx_memories_importance ON memories(importance_score DESC);
CREATE INDEX idx_memories_last_accessed ON memories(last_accessed_at);

-- ============================================================================
-- 关怀与提醒相关表
-- ============================================================================

-- 关怀计划表
CREATE TABLE care_schedules (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    companion_id INTEGER NOT NULL REFERENCES companions(id) ON DELETE CASCADE,

    -- 计划信息
    name VARCHAR(100) NOT NULL,
    schedule_type VARCHAR(20) CHECK (schedule_type IN ('daily', 'weekly', 'monthly', 'event', 'custom')),

    -- 时间配置
    time_pattern VARCHAR(50), -- cron表达式或简单时间 "08:00"
    timezone VARCHAR(50) DEFAULT 'Asia/Shanghai',

    -- 消息模板
    message_template TEXT,
    message_type VARCHAR(20) DEFAULT 'greeting' CHECK (message_type IN ('greeting', 'health', 'weather', 'reminder', 'encouragement')),

    -- 状态
    is_enabled BOOLEAN DEFAULT true,

    -- 执行统计
    total_sent INTEGER DEFAULT 0,
    last_sent_at TIMESTAMP,
    next_scheduled_at TIMESTAMP,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 关怀计划索引
CREATE INDEX idx_care_schedules_user_companion ON care_schedules(user_id, companion_id);
CREATE INDEX idx_care_schedules_next ON care_schedules(next_scheduled_at) WHERE is_enabled = true;

-- 关怀执行记录表
CREATE TABLE care_executions (
    id SERIAL PRIMARY KEY,
    schedule_id INTEGER NOT NULL REFERENCES care_schedules(id) ON DELETE CASCADE,
    message_id INTEGER REFERENCES messages(id) ON DELETE SET NULL,

    -- 执行信息
    status VARCHAR(20) CHECK (status IN ('success', 'failed', 'skipped')),
    error_message TEXT,

    -- 时间戳
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_care_executions_schedule_id ON care_executions(schedule_id);
CREATE INDEX idx_care_executions_executed_at ON care_executions(executed_at DESC);

-- ============================================================================
-- 媒体资源相关表
-- ============================================================================

-- 媒体资源表
CREATE TABLE media_assets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- 文件信息
    file_type VARCHAR(20) CHECK (file_type IN ('image', 'audio', 'video')),
    file_url TEXT NOT NULL,
    file_path VARCHAR(500), -- 本地路径或对象存储路径
    file_size INTEGER, -- 字节
    mime_type VARCHAR(50),

    -- 用途
    purpose VARCHAR(50), -- avatar, voice_sample, memory_image, etc.
    related_entity_type VARCHAR(50), -- companion, message, memory
    related_entity_id INTEGER,

    -- 处理状态
    processing_status VARCHAR(20) DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

-- 媒体资源索引
CREATE INDEX idx_media_assets_user_id ON media_assets(user_id);
CREATE INDEX idx_media_assets_purpose ON media_assets(purpose);
CREATE INDEX idx_media_assets_related ON media_assets(related_entity_type, related_entity_id);

-- ============================================================================
-- 订阅与支付相关表
-- ============================================================================

-- 订阅订单表
CREATE TABLE subscription_orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- 订单信息
    order_no VARCHAR(50) UNIQUE NOT NULL,
    subscription_type VARCHAR(20) NOT NULL,
    duration_months INTEGER NOT NULL,

    -- 金额
    original_price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2),
    final_price DECIMAL(10, 2) NOT NULL,

    -- 支付信息
    payment_method VARCHAR(20), -- wechat, alipay, etc.
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    paid_at TIMESTAMP,

    -- 订阅生效时间
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_subscription_orders_user_id ON subscription_orders(user_id);
CREATE INDEX idx_subscription_orders_order_no ON subscription_orders(order_no);
CREATE INDEX idx_subscription_orders_status ON subscription_orders(payment_status);

-- ============================================================================
-- 使用统计与分析表
-- ============================================================================

-- 每日使用统计
CREATE TABLE daily_usage_stats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stat_date DATE NOT NULL,

    -- 对话统计
    conversations_count INTEGER DEFAULT 0,
    messages_sent INTEGER DEFAULT 0,
    messages_received INTEGER DEFAULT 0,

    -- 时长统计
    total_duration_seconds INTEGER DEFAULT 0, -- 总使用时长

    -- AI使用统计
    text_messages INTEGER DEFAULT 0,
    voice_messages INTEGER DEFAULT 0,
    images_generated INTEGER DEFAULT 0,

    -- 费用统计（内部使用）
    ai_cost DECIMAL(10, 4) DEFAULT 0,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, stat_date)
);

CREATE INDEX idx_daily_usage_stats_user_date ON daily_usage_stats(user_id, stat_date DESC);

-- ============================================================================
-- 系统配置与日志表
-- ============================================================================

-- 系统配置表
CREATE TABLE system_configs (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'string', -- string, json, number, boolean
    description TEXT,
    is_public BOOLEAN DEFAULT false, -- 是否可公开访问

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 审计日志表
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,

    -- 操作信息
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,

    -- 详情
    description TEXT,
    ip_address INET,
    user_agent TEXT,

    -- 时间戳
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- 元数据
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);

-- ============================================================================
-- 触发器函数
-- ============================================================================

-- 更新 updated_at 时间戳的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间戳触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companions_updated_at BEFORE UPDATE ON companions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_care_schedules_updated_at BEFORE UPDATE ON care_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 更新对话消息计数的触发器函数
CREATE OR REPLACE FUNCTION update_conversation_message_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE conversations
        SET message_count = message_count + 1,
            last_message_at = NEW.created_at
        WHERE id = NEW.conversation_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE conversations
        SET message_count = GREATEST(message_count - 1, 0)
        WHERE id = OLD.conversation_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_message_count AFTER INSERT OR DELETE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_message_count();

-- ============================================================================
-- 初始数据
-- ============================================================================

-- 插入系统配置
INSERT INTO system_configs (config_key, config_value, config_type, description, is_public) VALUES
('app_name', '永伴', 'string', '应用名称', true),
('app_version', '1.0.0', 'string', '应用版本', true),
('max_free_messages_per_day', '20', 'number', '免费用户每日消息限额', false),
('max_premium_messages_per_day', '500', 'number', '付费用户每日消息限额', false),
('max_companions_free', '1', 'number', '免费用户最大角色数', false),
('max_companions_premium', '5', 'number', '付费用户最大角色数', false),
('enable_voice', 'true', 'boolean', '是否启用语音功能', true),
('enable_image_generation', 'true', 'boolean', '是否启用图像生成', true);

-- ============================================================================
-- 视图定义
-- ============================================================================

-- 用户统计视图
CREATE VIEW user_stats_view AS
SELECT
    u.id,
    u.nickname,
    u.subscription_type,
    COUNT(DISTINCT c.id) as companion_count,
    COUNT(DISTINCT conv.id) as conversation_count,
    COUNT(m.id) as message_count,
    MAX(m.created_at) as last_message_at
FROM users u
LEFT JOIN companions c ON c.user_id = u.id AND c.deleted_at IS NULL
LEFT JOIN conversations conv ON conv.user_id = u.id
LEFT JOIN messages m ON m.conversation_id = conv.id
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.nickname, u.subscription_type;

-- 活跃用户视图（最近7天有消息）
CREATE VIEW active_users_view AS
SELECT DISTINCT
    u.id,
    u.nickname,
    u.phone,
    u.subscription_type,
    MAX(m.created_at) as last_active_at
FROM users u
JOIN conversations conv ON conv.user_id = u.id
JOIN messages m ON m.conversation_id = conv.id
WHERE m.created_at >= CURRENT_DATE - INTERVAL '7 days'
    AND u.deleted_at IS NULL
GROUP BY u.id, u.nickname, u.phone, u.subscription_type;

-- ============================================================================
-- 注释
-- ============================================================================

COMMENT ON TABLE users IS '用户表 - 存储用户基本信息和订阅状态';
COMMENT ON TABLE companions IS '陪伴角色表 - 存储AI陪伴角色的配置信息';
COMMENT ON TABLE conversations IS '对话会话表 - 存储用户与角色的对话会话';
COMMENT ON TABLE messages IS '消息表 - 存储所有对话消息';
COMMENT ON TABLE memories IS '长期记忆表 - 存储提取的重要记忆';
COMMENT ON TABLE care_schedules IS '关怀计划表 - 存储主动关怀的定时任务';
COMMENT ON TABLE media_assets IS '媒体资源表 - 存储图片、音频等文件信息';
COMMENT ON TABLE subscription_orders IS '订阅订单表 - 存储订阅购买记录';

-- 完成
SELECT 'Database schema created successfully!' as status;
