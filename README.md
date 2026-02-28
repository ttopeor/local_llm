# Local LLM — 家庭局域网 AI 服务

## 硬件配置
- GPU: NVIDIA RTX PRO 6000 Blackwell (96GB VRAM)
- 本机 IP: 10.0.0.190

## 可用模型

| 模型 | 大小 | 类型 | 特点 |
|------|------|------|------|
| `gpt-oss:120b` | 65GB | 本地 | MoE 架构，接近 OpenAI o4-mini 水平 |
| `qwen3.5:122b` | 81GB | 本地 | 多模态，256k context，agent 工具调用友好 |
| `qwen2.5vl:72b` | 50GB | 本地 | 视觉语言模型，图像理解 |
| `qwen3.5:397b-cloud` | — | ☁️ 云端 | 397B MoE，Ollama 云推理，需登录 ollama.com |

## 首次安装

```bash
cd ~/Workspace/local-llm
bash setup.sh
```

安装内容：
- **Ollama** — 模型推理引擎
- **Open WebUI** — 家庭用的网页聊天界面

下载模型：
```bash
bash pull-model.sh gpt-oss        # 下载 gpt-oss:120b (65GB)
bash pull-model.sh qwen3.5        # 下载 qwen3.5:122b (81GB)
bash pull-model.sh qwen2.5vl      # 下载 qwen2.5vl:72b (50GB)
bash pull-model.sh qwen3.5-cloud  # 注册云端模型 (需先 ollama login)
bash pull-model.sh all            # 下载所有本地模型
```

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

# 测试 API（使用当前活跃模型）
bash test-api.sh
bash test-api.sh 10.0.0.190   # 从其他设备视角测试
```

## 切换模型

```bash
bash switch-model.sh
```

交互式菜单选择模型，选择会保存到 `.current-model`，`test-api.sh` 会自动读取。

## API 使用方法 (OpenAI 兼容)

**Python:**
```python
from openai import OpenAI

client = OpenAI(
    base_url="http://10.0.0.190:11434/v1",
    api_key="ollama",  # 任意字符串
)

response = client.chat.completions.create(
    model="qwen3.5:122b",   # 或 gpt-oss:120b
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

**curl:**
```bash
curl http://10.0.0.190:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.5:122b",
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
