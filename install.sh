#!/bin/bash
# 家庭信息发布平台 · Skill 安装脚本
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/ProphetKL/skills/main/install.sh | bash
#
# 可选参数（通过 bash -s -- 传入）：
#   --global      安装到 ~/.openclaw/workspace/skills/（OpenClaw 全局）
#   --claudecode  安装到 .claude/commands/（Claude Code）
#
# 示例：
#   curl -fsSL https://raw.githubusercontent.com/ProphetKL/skills/main/install.sh | bash -s -- --global
#   curl -fsSL https://raw.githubusercontent.com/ProphetKL/skills/main/install.sh | bash -s -- --claudecode

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

# ── 解析参数，默认 OpenClaw 本地 ──────────────
PLATFORM="openclaw-local"
INSTALL_DIR="./skills/whatsapp-发布"

for arg in "$@"; do
  case "$arg" in
    --global)
      PLATFORM="openclaw-global"
      INSTALL_DIR="$HOME/.openclaw/workspace/skills/whatsapp-发布"
      ;;
    --claudecode)
      PLATFORM="claudecode"
      INSTALL_DIR=".claude/commands"
      ;;
  esac
done

echo "  安装平台：$PLATFORM"
echo "  安装目录：$INSTALL_DIR"
echo ""

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

# ── 写入配置模板 ──────────────────────────────
CONFIG_FILE=".claude/whatsapp-config.json"

echo ""
if [ -f "$CONFIG_FILE" ]; then
  yellow "⚠ 已有配置文件：${CONFIG_FILE}，跳过创建。"
else
  mkdir -p ".claude"
  cat > "$CONFIG_FILE" <<'EOF'
{
  "ssh": {
    "host": "YOUR_SERVER_IP",
    "user": "root",
    "keyPath": "~/.ssh/id_rsa",
    "port": 22
  },
  "projectPath": "/root/whatsapp-bot/cloud",
  "auth": "admin:YOUR_PASSWORD"
}
EOF
  green "✓ 配置模板已创建：${CONFIG_FILE}"
  yellow "  请编辑该文件，填写你的服务器地址和密码。"
fi

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
