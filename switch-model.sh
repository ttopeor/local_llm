#!/bin/bash
# Switch the active LLM model
# Saves selection to .current-model, used by test-api.sh and other scripts

MODELS=(
    "gpt-oss:120b|65GB|GPT-OSS 120B (MoE, 接近 o4-mini, 本地)"
    "qwen3.5:122b|81GB|Qwen3.5 122B (多模态, agent 友好, 本地)"
    "qwen2.5vl:72b|50GB|Qwen2.5VL 72B (视觉语言模型, 本地)"
    "qwen3.5:397b-cloud|云端|Qwen3.5 397B MoE (云推理, 需登录 ollama.com)"
)

CONFIG_FILE="$(dirname "$0")/.current-model"
HOST="${OLLAMA_HOST:-localhost}"

# Read current model
current=""
if [[ -f "$CONFIG_FILE" ]]; then
    current=$(cat "$CONFIG_FILE")
fi

echo "=== 切换模型 ==="
echo ""

# Show menu
for i in "${!MODELS[@]}"; do
    IFS="|" read -r name size desc <<< "${MODELS[$i]}"
    marker=""
    [[ "$name" == "$current" ]] && marker=" <-- 当前"
    printf "  %d) %-22s  %-8s  %s%s\n" $((i+1)) "$name" "$size" "$desc" "$marker"
done
echo ""

read -rp "选择模型 (1-${#MODELS[@]}): " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#MODELS[@]} )); then
    echo "无效选择，退出。"
    exit 1
fi

IFS="|" read -r selected_name selected_size selected_desc <<< "${MODELS[$((choice-1))]}"

# Check if model is already pulled
echo ""
echo "==> 检查模型是否已下载..."
available=$(curl -s "http://${HOST}:11434/api/tags" | python3 -c "
import json,sys
data = json.load(sys.stdin)
names = [m['name'] for m in data.get('models', [])]
print('\n'.join(names))
" 2>/dev/null)

if ! echo "$available" | grep -qF "$selected_name"; then
    echo "    模型 $selected_name 未下载 (~${selected_size})。"
    read -rp "    现在拉取？(y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "==> 拉取 $selected_name ..."
        ollama pull "$selected_name"
    else
        echo "已取消。"
        exit 0
    fi
fi

# Save selection
echo "$selected_name" > "$CONFIG_FILE"
echo ""
echo "==> 已切换到: $selected_name"
echo "    $selected_desc"
