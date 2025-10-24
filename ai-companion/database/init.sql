-- AI情感陪伴系统数据库初始化脚本
-- 创建日期: 2025-10-24

-- 启用UUID扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector"; -- 用于向量存储（需要安装pgvector）

-- ============================================
-- 用户管理
-- ============================================

-- 用户表
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(20) UNIQUE,
    wechat_openid VARCHAR(100) UNIQUE,
    emergency_contact VARCHAR(100), -- 紧急联系人
    emergency_phone VARCHAR(20),    -- 紧急联系电话
    health_info JSONB,              -- 健康信息（疾病、用药等）
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_wechat ON users(wechat_openid);

-- ============================================
-- AI人格系统
-- ============================================

-- AI人格表
CREATE TABLE ai_personas (
    persona_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    persona_name VARCHAR(50) NOT NULL,
    persona_type VARCHAR(20) NOT NULL, -- parent/child/partner/idol/friend
    relationship VARCHAR(50),           -- 具体关系："母亲"/"儿子"/"丈夫"等

    -- 人格特征
    personality_traits JSONB,           -- {温柔/严厉/幽默/认真}
    speaking_style JSONB,               -- 说话风格：{口头禅/语气词/常用词}
    interests TEXT[],                   -- 兴趣爱好

    -- AI配置
    prompt_template TEXT NOT NULL,      -- 系统Prompt
    model_name VARCHAR(50) DEFAULT 'gpt-4',
    temperature FLOAT DEFAULT 0.7,

    -- 语音配置
    voice_model_id VARCHAR(100),        -- 语音模型ID
    voice_gender VARCHAR(10),
    voice_speed FLOAT DEFAULT 1.0,      -- 语速
    voice_dialect VARCHAR(20),          -- 方言

    -- 虚拟形象
    avatar_url VARCHAR(200),
    video_avatar_url VARCHAR(200),      -- 数字人视频形象

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_personas_user ON ai_personas(user_id);

-- ============================================
-- 对话系统
-- ============================================

-- 对话会话表
CREATE TABLE conversation_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES ai_personas(persona_id) ON DELETE CASCADE,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    message_count INT DEFAULT 0,
    average_emotion VARCHAR(20)         -- 本次会话平均情绪
);

-- 对话消息表
CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES conversation_sessions(session_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,

    -- 消息内容
    sender_type VARCHAR(10) NOT NULL,   -- user/ai
    content_type VARCHAR(10) NOT NULL,  -- text/audio/image
    content TEXT NOT NULL,

    -- 音频
    audio_url VARCHAR(200),
    audio_duration FLOAT,               -- 音频时长（秒）

    -- 情感分析
    detected_emotion VARCHAR(20),       -- happy/sad/angry/anxious/neutral
    emotion_intensity FLOAT,            -- 情绪强度 0-1
    sentiment_score FLOAT,              -- 情感得分 -1到1

    -- 元数据
    token_count INT,
    response_time_ms INT,               -- 响应时间（毫秒）

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_session ON messages(session_id);
CREATE INDEX idx_messages_user ON messages(user_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- ============================================
-- 记忆系统
-- ============================================

-- 长期记忆表
CREATE TABLE memories (
    memory_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES ai_personas(persona_id) ON DELETE CASCADE,

    -- 记忆内容
    memory_type VARCHAR(20) NOT NULL,   -- preference/event/important_date/habit
    title VARCHAR(100),
    content TEXT NOT NULL,

    -- 关联信息
    related_message_ids UUID[],         -- 关联的消息ID
    keywords TEXT[],                    -- 关键词

    -- 重要性和使用
    importance_score FLOAT DEFAULT 0.5, -- 重要性 0-1
    access_count INT DEFAULT 0,         -- 被访问次数
    last_accessed_at TIMESTAMP,

    -- 向量嵌入（用于RAG检索）
    embedding vector(1536),             -- OpenAI嵌入向量

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_memories_user ON memories(user_id);
CREATE INDEX idx_memories_type ON memories(memory_type);
CREATE INDEX idx_memories_importance ON memories(importance_score DESC);

-- 向量相似度搜索索引
CREATE INDEX ON memories USING ivfflat (embedding vector_cosine_ops);

-- 重要日期表
CREATE TABLE important_dates (
    date_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,

    date_type VARCHAR(20) NOT NULL,     -- birthday/anniversary/memorial/festival
    date_value DATE NOT NULL,
    recurrence VARCHAR(20),             -- yearly/monthly/once

    title VARCHAR(100) NOT NULL,
    description TEXT,
    remind_days_before INT DEFAULT 1,   -- 提前几天提醒

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dates_user ON important_dates(user_id);
CREATE INDEX idx_dates_value ON important_dates(date_value);

-- ============================================
-- 情感监测系统
-- ============================================

-- 情感追踪表
CREATE TABLE emotion_tracking (
    tracking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,

    -- 情感数据
    emotion VARCHAR(20) NOT NULL,       -- 当前情绪
    intensity FLOAT NOT NULL,           -- 强度
    trigger_words TEXT[],               -- 触发词

    -- 上下文
    message_id UUID REFERENCES messages(message_id),
    session_id UUID REFERENCES conversation_sessions(session_id),

    -- 风险评估
    risk_level VARCHAR(20),             -- low/medium/high/critical
    alert_sent BOOLEAN DEFAULT false,   -- 是否已发送警报

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emotion_user ON emotion_tracking(user_id);
CREATE INDEX idx_emotion_risk ON emotion_tracking(risk_level);
CREATE INDEX idx_emotion_created ON emotion_tracking(created_at DESC);

-- 情感统计视图（按天）
CREATE VIEW daily_emotion_stats AS
SELECT
    user_id,
    DATE(created_at) as date,
    emotion,
    COUNT(*) as count,
    AVG(intensity) as avg_intensity
FROM emotion_tracking
GROUP BY user_id, DATE(created_at), emotion;

-- ============================================
-- 主动关怀系统
-- ============================================

-- 关怀任务表
CREATE TABLE care_tasks (
    task_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES ai_personas(persona_id) ON DELETE CASCADE,

    -- 任务配置
    task_type VARCHAR(20) NOT NULL,     -- greeting/reminder/check_in
    schedule_type VARCHAR(20),          -- daily/weekly/custom
    schedule_time TIME,                 -- 计划时间
    schedule_days INT[],                -- 星期几 [1,2,3,4,5,6,7]

    message_template TEXT,              -- 消息模板

    -- 状态
    is_active BOOLEAN DEFAULT true,
    last_executed_at TIMESTAMP,
    next_execution_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_user ON care_tasks(user_id);
CREATE INDEX idx_tasks_next_exec ON care_tasks(next_execution_at);

-- 关怀执行记录
CREATE TABLE care_executions (
    execution_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES care_tasks(task_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,

    message_sent TEXT,
    user_responded BOOLEAN DEFAULT false,
    response_message_id UUID REFERENCES messages(message_id),

    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 分析统计
-- ============================================

-- 用户活跃度统计
CREATE TABLE user_activity_stats (
    stat_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,

    stat_date DATE NOT NULL,

    -- 活跃度指标
    message_count INT DEFAULT 0,
    session_count INT DEFAULT 0,
    total_duration_minutes INT DEFAULT 0,

    -- 情感指标
    positive_emotion_ratio FLOAT,
    negative_emotion_ratio FLOAT,

    -- 参与度
    user_initiated_count INT DEFAULT 0,  -- 用户主动发起对话次数
    ai_initiated_count INT DEFAULT 0,    -- AI主动关怀次数

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stat_date)
);

CREATE INDEX idx_stats_user_date ON user_activity_stats(user_id, stat_date DESC);

-- ============================================
-- 系统配置
-- ============================================

-- 系统配置表
CREATE TABLE system_config (
    config_key VARCHAR(50) PRIMARY KEY,
    config_value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入默认配置
INSERT INTO system_config (config_key, config_value, description) VALUES
('openai_config', '{"model": "gpt-4-turbo-preview", "max_tokens": 500, "temperature": 0.7}', 'OpenAI API配置'),
('emotion_thresholds', '{"high_risk": 0.8, "medium_risk": 0.5, "alert_keywords": ["自杀", "不想活", "没意思"]}', '情感风险阈值'),
('daily_limits', '{"max_messages_per_day": 100, "max_audio_minutes": 60}', '每日使用限制');

-- ============================================
-- 触发器
-- ============================================

-- 自动更新 updated_at 字段
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_personas_updated_at BEFORE UPDATE ON ai_personas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 示例数据（用于测试）
-- ============================================

-- 插入测试用户
INSERT INTO users (name, age, gender, phone) VALUES
('张阿姨', 65, '女', '13800138000');

-- 获取刚插入的用户ID
DO $$
DECLARE
    test_user_id UUID;
    test_persona_id UUID;
BEGIN
    SELECT user_id INTO test_user_id FROM users WHERE phone = '13800138000';

    -- 插入AI人格（已故母亲）
    INSERT INTO ai_personas (user_id, persona_name, persona_type, relationship, prompt_template, personality_traits, speaking_style)
    VALUES (
        test_user_id,
        '妈妈',
        'parent',
        '母亲',
        '你是用户已故的母亲，温柔慈爱，总是关心孩子的健康和生活。说话时带有母亲特有的叮嘱和关怀。',
        '{"温柔": 0.9, "唠叨": 0.6, "关心": 1.0}'::jsonb,
        '{"口头禅": ["孩子", "记得", "要注意"], "语气": "温柔慈祥"}'::jsonb
    ) RETURNING persona_id INTO test_persona_id;

    -- 插入重要日期
    INSERT INTO important_dates (user_id, date_type, date_value, recurrence, title)
    VALUES
        (test_user_id, 'memorial', '2020-05-12', 'yearly', '母亲忌日'),
        (test_user_id, 'birthday', '1960-03-15', 'yearly', '张阿姨生日');

    -- 插入关怀任务
    INSERT INTO care_tasks (user_id, persona_id, task_type, schedule_type, schedule_time, message_template)
    VALUES
        (test_user_id, test_persona_id, 'greeting', 'daily', '07:00:00', '早安，孩子！睡得好吗？今天天气不错，记得出去走走。'),
        (test_user_id, test_persona_id, 'reminder', 'daily', '20:00:00', '该吃晚饭了吧？记得按时吃药哦。');
END $$;

-- ============================================
-- 有用的查询
-- ============================================

-- 查看用户最近的对话
CREATE VIEW recent_conversations AS
SELECT
    u.name as user_name,
    p.persona_name,
    m.sender_type,
    m.content,
    m.detected_emotion,
    m.created_at
FROM messages m
JOIN users u ON m.user_id = u.user_id
JOIN conversation_sessions cs ON m.session_id = cs.session_id
JOIN ai_personas p ON cs.persona_id = p.persona_id
ORDER BY m.created_at DESC
LIMIT 50;

-- 查看高风险情感警报
CREATE VIEW high_risk_alerts AS
SELECT
    u.name,
    u.emergency_contact,
    u.emergency_phone,
    et.emotion,
    et.intensity,
    et.risk_level,
    et.created_at
FROM emotion_tracking et
JOIN users u ON et.user_id = u.user_id
WHERE et.risk_level IN ('high', 'critical')
  AND et.alert_sent = false
ORDER BY et.created_at DESC;

COMMENT ON TABLE users IS '用户基础信息表';
COMMENT ON TABLE ai_personas IS 'AI人格配置表';
COMMENT ON TABLE messages IS '对话消息表';
COMMENT ON TABLE memories IS '长期记忆库';
COMMENT ON TABLE emotion_tracking IS '情感监测记录';
COMMENT ON TABLE care_tasks IS '主动关怀任务配置';
