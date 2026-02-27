# Local LLM — gpt-oss:120b 家庭局域网 AI 服务

## 硬件配置
- GPU: NVIDIA RTX PRO 6000 Blackwell (96GB VRAM)
- 模型: gpt-oss:120b (65GB, MoE, 接近 OpenAI o4-mini 水平)
- 本机 IP: 10.0.0.190

## 首次安装

```bash
cd ~/Workspace/local-llm
bash setup.sh
```

安装内容：
- **Ollama** — 模型推理引擎
- **gpt-oss:120b** — 65GB 模型文件
- **Open WebUI** — 家庭用的网页聊天界面

## 日常使用

| 服务 | 地址 |
|------|------|
| 聊天界面 (家人用) | http://10.0.0.190:8080 |
| API 接口 (开发用) | http://10.0.0.190:11434/v1 |

```bash
# 启动服务
bash start.sh

# 停止服务
bash stop.sh

# 测试 API
bash test-api.sh
bash test-api.sh 10.0.0.190   # 从其他设备视角测试
```

## API 使用方法 (OpenAI 兼容)

**Python:**
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://10.0.0.190:11434/v1",
    api_key="ollama",  # 任意字符串
)

response = client.chat.completions.create(
    model="gpt-oss:120b",
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

**curl:**
```bash
curl http://10.0.0.190:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-oss:120b",
    "messages": [{"role": "user", "content": "你好！"}]
  }'
```

## 家人设备接入

在家庭成员的手机/电脑浏览器打开：
```
http://10.0.0.190:8080
```

## 服务管理

```bash
# 查看状态
systemctl status ollama
systemctl status local-llm-webui

# 开机自启（已配置）
sudo systemctl enable ollama
sudo systemctl enable local-llm-webui

# 日志
journalctl -u ollama -f
journalctl -u local-llm-webui -f
```
