#!/bin/bash
# Test whether the LLM services are reachable over the VPN.
# Run this from a remote machine connected to the VPN (or on the host itself).
#
# Usage:
#   ./test-vpn.sh                 # defaults to VPN IP 10.8.0.3
#   ./test-vpn.sh 10.8.0.3        # explicit host
#   VPN_HOST=10.8.0.3 ./test-vpn.sh

VPN_HOST="${1:-${VPN_HOST:-10.8.0.3}}"
OLLAMA_PORT=11434
WEBUI_PORT=8080
TIMEOUT=8

# Read current model (used for the chat test), fallback to gpt-oss:120b
CONFIG_FILE="$(dirname "$0")/.current-model"
if [[ -f "$CONFIG_FILE" ]]; then
    MODEL=$(cat "$CONFIG_FILE")
else
    MODEL="gpt-oss:120b"
fi

PASS=0
FAIL=0

ok()   { echo "  [ OK ] $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

echo "=== VPN 连通性测试 ==="
echo "目标主机 : $VPN_HOST"
echo "活动模型 : $MODEL"
echo ""

# 1) Reachability (ping). Some VPNs block ICMP, so this is informational only.
echo "=== 1. 主机可达性 (ping) ==="
if ping -c 2 -W 3 "$VPN_HOST" >/dev/null 2>&1; then
    ok "$VPN_HOST 可 ping 通"
else
    echo "  [WARN] ping 不通 (部分 VPN 屏蔽 ICMP，继续测端口)"
fi
echo ""

# 2) Ollama API port
echo "=== 2. Ollama API ($VPN_HOST:$OLLAMA_PORT) ==="
tags=$(curl -s --max-time "$TIMEOUT" "http://${VPN_HOST}:${OLLAMA_PORT}/api/tags" 2>/dev/null)
if [[ -n "$tags" ]] && echo "$tags" | grep -q '"models"'; then
    ok "Ollama API 可访问"
    echo "$tags" | python3 -c "
import json,sys
data = json.load(sys.stdin)
print('  可用模型:')
for m in data.get('models', []):
    print(f\"    - {m['name']}  ({m['size']/1e9:.1f} GB)\")
" 2>/dev/null
else
    bad "无法访问 Ollama API (端口未开放 / VPN 不通 / 服务未启动)"
fi
echo ""

# 3) Open WebUI port
echo "=== 3. Open WebUI ($VPN_HOST:$WEBUI_PORT) ==="
code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "http://${VPN_HOST}:${WEBUI_PORT}/" 2>/dev/null)
if [[ "$code" == "200" ]]; then
    ok "Open WebUI 可访问 (HTTP $code)  ->  http://${VPN_HOST}:${WEBUI_PORT}"
else
    bad "无法访问 Open WebUI (HTTP ${code:-无响应})"
fi
echo ""

# 4) End-to-end chat test through the VPN.
# Use the native /api/chat endpoint with an explicit small num_ctx: the
# OpenAI-compatible /v1 endpoint ignores num_ctx and would fall back to the
# model's huge default context, which can exhaust GPU memory on load.
echo "=== 4. 推理测试 (原生 /api/chat) ==="
resp=$(curl -s --max-time 240 "http://${VPN_HOST}:${OLLAMA_PORT}/api/chat" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$MODEL\",
        \"messages\": [{\"role\": \"user\", \"content\": \"Reply with exactly: VPN OK\"}],
        \"stream\": false,
        \"options\": {\"num_ctx\": 2048}
    }" 2>/dev/null)
msg=$(echo "$resp" | python3 -c "
import json,sys
try:
    print(json.load(sys.stdin)['message']['content'].strip())
except Exception:
    pass
" 2>/dev/null)
if [[ -n "$msg" ]]; then
    ok "模型已响应: $msg"
else
    bad "推理请求失败 (模型可能未加载，或加载超时)"
fi
echo ""

# Summary
echo "=== 结果 ==="
echo "  通过 $PASS / 失败 $FAIL"
if (( FAIL == 0 )); then
    echo "  VPN 远程访问正常 ✅"
    exit 0
else
    echo "  存在问题，请检查上面 [FAIL] 项 ❌"
    exit 1
fi
