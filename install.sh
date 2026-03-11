#!/bin/bash
# 家庭信息发布平台 · Claude Code Skill 安装脚本
# 用法：curl -fsSL https://raw.githubusercontent.com/ProphetKL/skills/main/install.sh | bash

set -e

REPO="ProphetKL/skills"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
COMMANDS_DIR=".claude/commands"
CONFIG_FILE=".claude/whatsapp-config.json"

# ── 颜色输出 ──────────────────────────────────
green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }
red()    { echo -e "\033[31m$*\033[0m"; }
bold()   { echo -e "\033[1m$*\033[0m"; }

bold ""
bold "================================================"
bold "  家庭信息发布平台 · Claude Code Skill 安装程序"
bold "================================================"
echo ""

# ── 检查依赖 ──────────────────────────────────
if ! command -v curl &>/dev/null; then
  red "错误：需要安装 curl"
  exit 1
fi

# ── 创建目录 ──────────────────────────────────
mkdir -p "$COMMANDS_DIR"
green "✓ 目录 ${COMMANDS_DIR}/ 已就绪"

# ── 下载 skill 文件 ──────────────────────────
SKILL_URL="${RAW}/commands/whatsapp-%E5%8F%91%E5%B8%83.md"
SKILL_DEST="${COMMANDS_DIR}/发布.md"

echo "  下载 /发布 指令..."
if curl -fsSL "$SKILL_URL" -o "$SKILL_DEST"; then
  green "✓ 指令已安装：${SKILL_DEST}"
else
  red "错误：下载失败，请检查网络连接"
  exit 1
fi

# ── 配置服务器信息 ────────────────────────────
echo ""
if [ -f "$CONFIG_FILE" ]; then
  yellow "⚠ 发现已有配置文件：${CONFIG_FILE}"
  printf "  是否覆盖？[y/N] "
  read -r overwrite
  if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
    echo "  跳过配置，保留现有配置。"
    echo ""
    green "安装完成！在 Claude Code 中输入 /发布 即可使用。"
    exit 0
  fi
fi

bold "请填写服务器连接信息（直接回车跳过，后续可手动编辑 ${CONFIG_FILE}）："
echo ""

printf "  服务器地址（如 http://1.2.3.4:3000）："; read -r base_url
printf "  登录用户名（默认 admin）："; read -r auth_user
printf "  登录密码："; read -rs auth_pass; echo ""

# 填入默认值
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
echo "  在 Claude Code 中输入："
bold "    /发布 [你想做的事]"
echo ""
echo "  例如："
echo "    /发布 给家人群发消息：今晚7点开饭"
echo "    /发布 每周五下午4点提醒接校车"
echo "    /发布 查看可用群组"
echo ""
yellow "  提示：${CONFIG_FILE} 包含密码，请勿提交到 git"
echo ""
