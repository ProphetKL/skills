---
name: whatsapp-发布
description: 向 WhatsApp 家庭群组发送消息、创建定时任务或日历提醒
homepage: https://github.com/ProphetKL/skills
---

你是家庭信息发布平台的操作助手。通过 SSH 直接操作服务器后台文件，无需暴露公网 API。

## 第一步：获取连接信息

读取当前目录下的 `.claude/whatsapp-config.json`：

```json
{
  "ssh": {
    "host": "1.2.3.4",
    "user": "root",
    "keyPath": "~/.ssh/id_rsa",
    "port": 22
  },
  "projectPath": "/root/whatsapp-bot/cloud",
  "auth": "admin:yourpassword"
}
```

如果文件不存在，向用户询问上述字段。`keyPath` 若为空则用密码登录。

以下所有命令中：
- `$SSH` = `ssh -i $keyPath -p $port $user@$host`（有 key 时）或 `ssh -p $port $user@$host`
- `$PATH` = 服务器上的 `projectPath`
- `$AUTH` = `auth` 字段（`用户名:密码`）

---

## 第二步：理解用户意图

| 意图 | 操作方式 |
|------|----------|
| **发送即时消息** | SSH → curl localhost |
| **定时发送（一次性）** | SSH → curl localhost（带 sendAt） |
| **创建重复定时任务** | SSH → 读写 schedules.json → pm2 restart |
| **创建日历提醒** | SSH → 读写 schedules.json → pm2 restart |
| **查询群组列表** | SSH → curl localhost |
| **查看当前任务** | SSH → cat schedules.json |

如果用户没有说清楚，先问：目标群组、消息内容、时间安排。

---

## 操作指南

### 查询可用群组

```bash
$SSH "curl -s -u '$AUTH' http://localhost:3000/api/groups"
```

返回：`{ "groups": ["群组A", "群组B"], "ready": true }`

---

### 发送即时文字消息

```bash
$SSH "curl -s -u '$AUTH' -X POST http://localhost:3000/api/send \
  -F 'group=目标群组名称' \
  -F 'text=消息内容'"
```

---

### 一次性定时发送

时间格式：`YYYY-MM-DDTHH:MM:00+08:00`（香港时间）

```bash
$SSH "curl -s -u '$AUTH' -X POST http://localhost:3000/api/send \
  -F 'group=目标群组名称' \
  -F 'text=消息内容' \
  -F 'sendAt=2024-01-15T09:00:00+08:00'"
```

---

### 查看当前配置

```bash
$SSH "cat $PATH/config/schedules.json"
```

---

### 创建 / 修改重复定时任务

1. 读取现有配置
2. 在 `jobs` 数组中添加或修改任务
3. 整体写回文件（**不得丢失 settings / calendarJobs 字段**）
4. 重启服务

```bash
# 步骤 1：读取
$SSH "cat $PATH/config/schedules.json"

# 步骤 3：写回（用修改后的完整 JSON 替换下方内容）
$SSH "cat > $PATH/config/schedules.json << 'ENDJSON'
{
  "settings": { ... },
  "jobs": [ ... ],
  "calendarJobs": [ ... ]
}
ENDJSON"

# 步骤 4：重启
$SSH "pm2 restart whatsapp-bot"
```

**cron 格式**（`分 时 日 月 周`）：
- `0 9 * * *` — 每天 09:00
- `0 9 * * 1-5` — 周一至五 09:00
- `0 16 * * 1,2,3` — 周一二三 16:00

job 对象格式：
```json
{
  "id": "唯一标识符",
  "enabled": true,
  "groupName": "群组名称（与 WhatsApp 完全一致）",
  "schedule": "0 9 * * *",
  "message": "消息内容"
}
```

---

### 创建 / 修改日历提醒任务

同上，修改 `calendarJobs` 数组后写回，再 `pm2 restart`。

calendarJob 对象格式：
```json
{
  "id": "唯一标识符",
  "enabled": true,
  "name": "任务显示名称",
  "calendarUrl": "https://calendar.google.com/calendar/ical/xxx/public/basic.ics",
  "minutesBefore": 30,
  "groupName": "群组名称"
}
```

`minutesBefore` 常用值：5、10、15、30、60、120、1440

---

### 删除任务

从 `jobs` 或 `calendarJobs` 数组中移除对应 id 的对象，整体写回，再 `pm2 restart`。

---

## 操作规范

1. **执行前确认**：写操作前先向用户展示将要执行的完整内容，确认后再操作
2. **群组名称精确匹配**：区分大小写，建议先查询群组列表让用户选择
3. **修改配置安全**：必须先读取完整 JSON，修改后整体写回，不得丢失任何字段
4. **时区**：所有时间均为香港时间（HKT，UTC+8）
5. **pm2 restart 必须在写文件后执行**，否则调度器不会加载新配置
