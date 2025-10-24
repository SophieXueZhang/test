"""
AI服务集成
"""
import openai
from typing import List, Dict, Optional
from app.core.config import settings

# 配置OpenAI
openai.api_key = settings.OPENAI_API_KEY


class AIService:
    """AI对话服务"""

    @staticmethod
    async def generate_response(
        system_prompt: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 500,
    ) -> Dict:
        """
        生成AI回复

        Args:
            system_prompt: 系统提示词
            messages: 对话历史 [{"role": "user", "content": "..."}]
            temperature: 温度参数
            max_tokens: 最大token数

        Returns:
            {"content": "回复内容", "tokens": 使用的token数}
        """
        try:
            # 构建消息列表
            full_messages = [{"role": "system", "content": system_prompt}] + messages

            # 调用OpenAI API
            response = await openai.ChatCompletion.acreate(
                model=settings.OPENAI_MODEL,
                messages=full_messages,
                temperature=temperature,
                max_tokens=max_tokens,
            )

            content = response.choices[0].message.content
            tokens_used = response.usage.total_tokens

            return {
                "content": content,
                "tokens": tokens_used,
                "model": settings.OPENAI_MODEL,
            }

        except Exception as e:
            print(f"AI生成失败: {str(e)}")
            raise Exception(f"AI服务错误: {str(e)}")

    @staticmethod
    async def generate_embedding(text: str) -> List[float]:
        """
        生成文本嵌入向量

        Args:
            text: 文本内容

        Returns:
            向量列表
        """
        try:
            response = await openai.Embedding.acreate(
                model=settings.OPENAI_EMBEDDING_MODEL,
                input=text,
            )

            return response.data[0].embedding

        except Exception as e:
            print(f"向量生成失败: {str(e)}")
            raise Exception(f"向量服务错误: {str(e)}")

    @staticmethod
    async def analyze_emotion(text: str) -> Dict:
        """
        分析文本情感

        Args:
            text: 文本内容

        Returns:
            {"emotion": "happy", "sentiment": "positive", "score": 0.8}
        """
        try:
            prompt = f"""分析以下文本的情感状态，返回JSON格式：
{{
    "emotion": "情绪类型（happy/sad/angry/anxious/neutral/excited/tired/grateful等）",
    "sentiment": "情感倾向（positive/negative/neutral）",
    "score": "置信度分数（0-1之间的浮点数）"
}}

文本：{text}

只返回JSON，不要其他内容。"""

            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                max_tokens=100,
            )

            import json
            result = json.loads(response.choices[0].message.content)
            return result

        except Exception as e:
            print(f"情感分析失败: {str(e)}")
            # 返回默认值
            return {
                "emotion": "neutral",
                "sentiment": "neutral",
                "score": 0.5,
            }

    @staticmethod
    async def extract_memory(conversation_context: str) -> Optional[Dict]:
        """
        从对话中提取重要记忆

        Args:
            conversation_context: 对话上下文

        Returns:
            {"type": "preference", "content": "用户喜欢...", "importance": 0.8}
        """
        try:
            prompt = f"""从以下对话中提取值得长期记忆的重要信息。
只提取以下类型的信息：
- fact: 用户的基本事实（职业、家庭等）
- preference: 用户的喜好
- habit: 用户的习惯
- event: 重要事件
- relationship: 人际关系信息

如果有重要信息，返回JSON格式：
{{
    "type": "类型",
    "content": "简洁的记忆描述",
    "importance": "重要性分数0-1"
}}

如果没有重要信息，返回：{{"extract": false}}

对话：
{conversation_context}

只返回JSON，不要其他内容。"""

            response = await openai.ChatCompletion.acreate(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                max_tokens=200,
            )

            import json
            result = json.loads(response.choices[0].message.content)

            if result.get("extract") == False:
                return None

            return result

        except Exception as e:
            print(f"记忆提取失败: {str(e)}")
            return None
