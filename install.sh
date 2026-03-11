#!/bin/bash
# 家庭信息发布平台 · Skill 安装脚本
# 支持 Claude Code 和 OpenClaw 两种平台
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/ProphetKL/skills/main/install.sh | bash

set -e

REPO="ProphetKL/skills"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# ── 颜色输出 ──────────────────────────────────
green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }
red()    { echo -e "\033[31m$*\033[0m"; }
bold()   { echo -e "\033[1m$*\033[0m"; }

bold ""
bold "================================================"
bold "  家庭信息发布平台 · Skill 安装程序"
bold "================================================"
echo ""

# ── 检查依赖 ──────────────────────────────────
if ! command -v curl &>/dev/null; then
  red "错误：需要安装 curl"; exit 1
fi

# ── 检测平台 ──────────────────────────────────
detect_platform() {
  if command -v openclaw &>/dev/null || [ -d "$HOME/.openclaw" ]; then
    echo "openclaw"
  else
    echo "claudecode"
  fi
}

PLATFORM=$(detect_platform)

echo "  检测到平台：$PLATFORM"
echo ""
echo "  请选择安装平台："
echo "  1) Claude Code（默认，安装到 .claude/commands/）"
echo "  2) OpenClaw（安装到 ./skills/ 目录）"
echo "  3) OpenClaw 全局（安装到 ~/.openclaw/skills/）"
printf "  请输入选项 [1/2/3，直接回车默认 1]："
read -r choice

case "${choice:-1}" in
  2)
    PLATFORM="openclaw-local"
    INSTALL_DIR="./skills/whatsapp-发布"
    ;;
  3)
    PLATFORM="openclaw-global"
    INSTALL_DIR="$HOME/.openclaw/skills/whatsapp-发布"
    ;;
  *)
    PLATFORM="claudecode"
    INSTALL_DIR=".claude/commands"
    ;;
esac

# ── 安装 ──────────────────────────────────────
mkdir -p "$INSTALL_DIR"

if [ "$PLATFORM" = "claudecode" ]; then
  # Claude Code：下载 .md 到 .claude/commands/
  SKILL_URL="${RAW}/commands/whatsapp-%E5%8F%91%E5%B8%83.md"
  SKILL_DEST="${INSTALL_DIR}/发布.md"
  echo "  下载 Claude Code skill..."
  curl -fsSL "$SKILL_URL" -o "$SKILL_DEST" || { red "下载失败"; exit 1; }
  green "✓ 已安装：${SKILL_DEST}"
  echo "  使用方法：在 Claude Code 中输入 /发布"
else
  # OpenClaw：下载 SKILL.md 到 skills/whatsapp-发布/
  SKILL_URL="${RAW}/whatsapp-%E5%8F%91%E5%B8%83/SKILL.md"
  SKILL_DEST="${INSTALL_DIR}/SKILL.md"
  echo "  下载 OpenClaw skill..."
  curl -fsSL "$SKILL_URL" -o "$SKILL_DEST" || { red "下载失败"; exit 1; }
  green "✓ 已安装：${SKILL_DEST}"
  echo "  使用方法：在 OpenClaw 中直接说「帮我发消息到 WhatsApp」"
fi

# ── 配置服务器信息 ────────────────────────────
CONFIG_FILE=".claude/whatsapp-config.json"

echo ""
if [ -f "$CONFIG_FILE" ]; then
  yellow "⚠ 发现已有配置文件：${CONFIG_FILE}"
  printf "  是否覆盖？[y/N] "
  read -r overwrite
  if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
    echo "  跳过配置，保留现有配置。"
    echo ""
    green "安装完成！"
    exit 0
  fi
fi

bold "请填写服务器连接信息（直接回车跳过，后续可手动编辑 ${CONFIG_FILE}）："
echo ""
printf "  服务器地址（如 http://1.2.3.4:3000）："; read -r base_url
printf "  登录用户名（默认 admin）："; read -r auth_user
printf "  登录密码："; read -rs auth_pass; echo ""

base_url="${base_url:-http://YOUR_SERVER_IP:3000}"
auth_user="${auth_user:-admin}"
auth_pass="${auth_pass:-YOUR_PASSWORD}"

mkdir -p ".claude"
cat > "$CONFIG_FILE" <<EOF
{
  "baseUrl": "${base_url}",
  "user": "${auth_user}",
  "pass": "${auth_pass}"
}
EOF
green "✓ 配置已保存：${CONFIG_FILE}"

# ── 完成 ──────────────────────────────────────
echo ""
bold "================================================"
green "  安装完成！"
bold "================================================"
echo ""
if [ "$PLATFORM" = "claudecode" ]; then
  echo "  在 Claude Code 中输入："
  bold "    /发布 [你想做的事]"
else
  echo "  在 OpenClaw 中直接描述任务，例如："
  bold "    帮我给家人群发消息：今晚7点开饭"
fi
echo ""
yellow "  提示：${CONFIG_FILE} 包含密码，请勿提交到 git"
echo ""
