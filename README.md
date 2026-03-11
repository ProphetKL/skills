# Claude Code Skills

个人 Claude Code 自定义指令集合（slash commands）。

## 安装方式

把 `commands/` 目录下的 `.md` 文件复制到你的项目根目录 `.claude/commands/` 即可使用对应的 `/指令名`。

---

## 可用指令

### `/发布` — 家庭信息发布平台助手

**文件：** `commands/whatsapp-发布.md`

帮助向 WhatsApp 家庭群组发送消息、创建定时任务、创建日历提醒。

**功能：**
- 📢 即时发送文字消息到 WhatsApp 群组
- ⏰ 一次性定时发送
- 🔁 创建重复定时任务（每天/每周/每月）
- 📅 创建 Google Calendar ICS 日历提醒
- 📋 查询群组列表、待发消息

**使用前置：**

在项目的 `.claude/whatsapp-config.json` 中填写连接信息：

```json
{
  "baseUrl": "http://YOUR_SERVER_IP:3000",
  "user": "admin",
  "pass": "YOUR_PASSWORD"
}
```

**使用示例：**

```
/发布 给金金家香港群发一条消息：提醒大家今晚7点开饭
/发布 每周五下午4点提醒接校车
/发布 查看有哪些群组
```

---

## 项目配套

此指令集配套 [whatsapp-bot](https://github.com/ProphetKL/whatsapp-bot) 项目使用。
