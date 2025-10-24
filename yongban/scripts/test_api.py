#!/usr/bin/env python3
"""
永伴 API 测试脚本

演示如何使用永伴API进行基本操作
"""
import requests
import json
from typing import Optional

BASE_URL = "http://localhost:8000/api/v1"


class YongbanAPIClient:
    """永伴API客户端"""

    def __init__(self, base_url: str = BASE_URL):
        self.base_url = base_url
        self.access_token: Optional[str] = None
        self.user_id: Optional[int] = None

    def register(self, phone: str, password: str, nickname: str = None):
        """用户注册"""
        print(f"\n📝 注册新用户: {phone}")
        response = requests.post(
            f"{self.base_url}/auth/register",
            json={
                "phone": phone,
                "password": password,
                "nickname": nickname or f"用户{phone[-4:]}",
            },
        )
        data = response.json()

        if data.get("success"):
            self.access_token = data["data"]["tokens"]["access_token"]
            self.user_id = data["data"]["user"]["id"]
            print(f"✅ 注册成功! 用户ID: {self.user_id}")
            print(f"🎫 Access Token: {self.access_token[:50]}...")
        else:
            print(f"❌ 注册失败: {data.get('message')}")

        return data

    def login(self, phone: str, password: str):
        """用户登录"""
        print(f"\n🔐 用户登录: {phone}")
        response = requests.post(
            f"{self.base_url}/auth/login",
            json={"phone": phone, "password": password},
        )
        data = response.json()

        if data.get("success"):
            self.access_token = data["data"]["tokens"]["access_token"]
            self.user_id = data["data"]["user"]["id"]
            print(f"✅ 登录成功! 用户ID: {self.user_id}")
        else:
            print(f"❌ 登录失败: {data.get('message')}")

        return data

    def get_headers(self):
        """获取请求头"""
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    def get_profile(self):
        """获取用户信息"""
        print(f"\n👤 获取用户信息")
        response = requests.get(
            f"{self.base_url}/users/me", headers=self.get_headers()
        )
        data = response.json()

        if data.get("success"):
            user = data["data"]
            print(f"✅ 用户: {user['nickname']} ({user['phone']})")
            print(f"   订阅类型: {user['subscription_type']}")
            print(f"   对话数: {user['total_conversations']}")
            print(f"   消息数: {user['total_messages']}")
        else:
            print(f"❌ 获取失败: {data.get('message')}")

        return data

    def create_companion(
        self, name: str, relationship: str, background: str, personality: dict = None
    ):
        """创建陪伴角色"""
        print(f"\n👥 创建陪伴角色: {name} ({relationship})")
        response = requests.post(
            f"{self.base_url}/companions",
            headers=self.get_headers(),
            json={
                "name": name,
                "relationship": relationship,
                "background_story": background,
                "personality": personality
                or {"traits": ["caring", "patient"], "tone": "warm"},
            },
        )
        data = response.json()

        if data.get("success"):
            companion = data["data"]
            print(f"✅ 角色创建成功! ID: {companion['id']}")
            print(f"   名字: {companion['name']}")
            print(f"   关系: {companion['relationship']}")
            return companion
        else:
            print(f"❌ 创建失败: {data.get('message')}")
            return None

    def list_companions(self):
        """获取角色列表"""
        print(f"\n📋 获取角色列表")
        response = requests.get(
            f"{self.base_url}/companions", headers=self.get_headers()
        )
        data = response.json()

        if data.get("success"):
            companions = data["data"]
            print(f"✅ 找到 {len(companions)} 个角色:")
            for c in companions:
                print(f"   - {c['name']} (ID: {c['id']}, {c['relationship']})")
            return companions
        else:
            print(f"❌ 获取失败: {data.get('message')}")
            return []

    def chat(self, companion_id: int, message: str, conversation_id: int = None):
        """发送消息"""
        print(f"\n💬 发送消息: {message}")
        response = requests.post(
            f"{self.base_url}/conversations/chat",
            headers=self.get_headers(),
            json={
                "companion_id": companion_id,
                "message": message,
                "conversation_id": conversation_id,
                "include_voice": False,
            },
        )
        data = response.json()

        if data.get("success"):
            chat_data = data["data"]
            assistant_msg = chat_data["assistant_message"]
            print(f"✅ 收到回复:")
            print(f"   {assistant_msg['content']}")
            print(f"   情绪: {assistant_msg.get('emotion', 'N/A')}")
            return chat_data
        else:
            print(f"❌ 发送失败: {data.get('message')}")
            return None

    def get_conversations(self, companion_id: int = None):
        """获取对话列表"""
        print(f"\n📜 获取对话历史")
        params = {"companion_id": companion_id} if companion_id else {}
        response = requests.get(
            f"{self.base_url}/conversations", headers=self.get_headers(), params=params
        )
        data = response.json()

        if data.get("success"):
            conversations = data["data"]
            print(f"✅ 找到 {len(conversations)} 个对话:")
            for conv in conversations:
                print(
                    f"   - 对话#{conv['id']}: {conv['title']} ({conv['message_count']}条消息)"
                )
            return conversations
        else:
            print(f"❌ 获取失败: {data.get('message')}")
            return []


def demo_basic_flow():
    """演示基本流程"""
    print("=" * 60)
    print("🎉 永伴 API 演示")
    print("=" * 60)

    client = YongbanAPIClient()

    # 1. 注册用户
    phone = "13900139000"
    password = "test123456"
    client.register(phone, password, "测试用户")

    # 2. 获取用户信息
    client.get_profile()

    # 3. 创建陪伴角色
    companion = client.create_companion(
        name="妈妈",
        relationship="parent",
        background="一位慈爱的母亲，生前最爱做饭，总是关心孩子的生活起居。",
        personality={"traits": ["caring", "patient", "warm"], "tone": "gentle"},
    )

    if not companion:
        print("\n⚠️  角色创建失败，停止演示")
        return

    companion_id = companion["id"]

    # 4. 开始对话
    print("\n" + "=" * 60)
    print("💭 开始对话")
    print("=" * 60)

    messages = [
        "妈妈，我今天有点累",
        "工作太忙了，都没时间好好吃饭",
        "好的妈妈，我会注意的",
    ]

    conversation_id = None
    for msg in messages:
        chat_data = client.chat(companion_id, msg, conversation_id)
        if chat_data and not conversation_id:
            conversation_id = chat_data["conversation_id"]

    # 5. 查看对话历史
    client.get_conversations(companion_id)

    # 6. 查看所有角色
    client.list_companions()

    print("\n" + "=" * 60)
    print("✨ 演示完成!")
    print("=" * 60)


def demo_login_flow():
    """演示登录流程"""
    print("\n" + "=" * 60)
    print("🔐 登录演示")
    print("=" * 60)

    client = YongbanAPIClient()

    # 使用测试数据中的用户登录
    client.login("13800138000", "password123")
    client.get_profile()
    companions = client.list_companions()

    if companions:
        # 与第一个角色对话
        companion = companions[0]
        client.chat(companion["id"], "今天天气真好！")


if __name__ == "__main__":
    import sys

    print("\n请选择演示模式:")
    print("1. 完整演示（注册 -> 创建角色 -> 对话）")
    print("2. 登录演示（使用测试数据）")

    choice = input("\n请输入选项 (1/2): ").strip()

    try:
        if choice == "1":
            demo_basic_flow()
        elif choice == "2":
            demo_login_flow()
        else:
            print("无效的选项!")
            sys.exit(1)
    except requests.exceptions.ConnectionError:
        print("\n❌ 无法连接到服务器!")
        print("请确保后端服务已启动: docker-compose up -d")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 发生错误: {str(e)}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
