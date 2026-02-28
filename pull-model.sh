#!/bin/bash
# Pull LLM models for local use
# Usage: bash pull-model.sh [model]
#   model: gpt-oss (default), qwen3.5, qwen2.5vl, qwen2.5vl-32b, qwen2.5vl-7b, all

TARGET="${1:-gpt-oss}"

pull_gpt_oss() {
    echo "Pulling gpt-oss:120b (~65GB, this will take a while)..."
    ollama pull gpt-oss:120b
    echo "Done! gpt-oss:120b ready."
}

pull_qwen35() {
    echo "Pulling qwen3.5:122b (~81GB, this will take a while)..."
    ollama pull qwen3.5:122b
    echo "Done! qwen3.5:122b ready."
}

pull_qwen25vl() {
    echo "Pulling qwen2.5vl:72b (~50GB, this will take a while)..."
    ollama pull qwen2.5vl:72b
    echo "Done! qwen2.5vl:72b ready."
}

pull_qwen25vl_32b() {
    echo "Pulling qwen2.5vl:32b (~21GB)..."
    ollama pull qwen2.5vl:32b
    echo "Done! qwen2.5vl:32b ready."
}

pull_qwen25vl_7b() {
    echo "Pulling qwen2.5vl:7b (~5GB)..."
    ollama pull qwen2.5vl:7b
    echo "Done! qwen2.5vl:7b ready."
}

pull_qwen35_cloud() {
    echo "Registering qwen3.5:397b-cloud (cloud model, no download needed)..."
    echo "  注意：需要登录 ollama.com 账号才能使用"
    echo "  登录命令：ollama login"
    ollama pull qwen3.5:397b-cloud
    echo "Done! qwen3.5:397b-cloud ready (cloud inference, 397B MoE)."
}

case "$TARGET" in
    gpt-oss)          pull_gpt_oss ;;
    qwen3.5)          pull_qwen35 ;;
    qwen2.5vl)        pull_qwen25vl ;;
    qwen2.5vl-32b)    pull_qwen25vl_32b ;;
    qwen2.5vl-7b)     pull_qwen25vl_7b ;;
    qwen3.5-cloud)    pull_qwen35_cloud ;;
    all)              pull_gpt_oss; pull_qwen35; pull_qwen25vl; pull_qwen25vl_32b; pull_qwen25vl_7b ;;
    *)
        echo "Usage: bash pull-model.sh [model]"
        echo ""
        echo "  gpt-oss        — gpt-oss:120b        (65GB, 本地)"
        echo "  qwen3.5        — qwen3.5:122b         (81GB, 本地)"
        echo "  qwen2.5vl      — qwen2.5vl:72b        (50GB, 本地, 视觉)"
        echo "  qwen2.5vl-32b  — qwen2.5vl:32b        (21GB, 本地, 视觉)"
        echo "  qwen2.5vl-7b   — qwen2.5vl:7b         (5GB, 本地, 视觉)"
        echo "  qwen3.5-cloud  — qwen3.5:397b-cloud   (云端, 需登录 ollama.com)"
        echo "  all            — 下载所有本地模型"
        exit 1
        ;;
esac
