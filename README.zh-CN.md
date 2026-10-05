<div align="center">

# 🎮 Sefidan CSS v34 服务器

### 完整的 Counter-Strike: Source v34 服务器 — 插件、Web 管理面板、游戏模式等

**🌐 语言:** [English](README.md) · [فارسی](README.fa.md) · [中文](README.zh-CN.md) · [العربية](README.ar.md) · [Русский](README.ru.md)

[![Stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=social)](https://github.com/armadgarsone2/cssv34-server/stargazers)
[![SourceMod](https://img.shields.io/badge/SourceMod-1.7.3-blue)](https://www.sourcemod.net/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

⭐ **如果这个项目对你有帮助，请点个 Star！** ⭐
只需要 2 秒钟，就能帮助更多人发现它。

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?label=给这个仓库点Star&style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>

---

## 🌐 我们的在线服务器

| | |
|---|---|
| 🎮 **连接地址** | `147.185.221.215:19303` |
| 🖥 **引擎** | CS:S v34 (ClientMod) |
| ⚡ **Tickrate** | 100 |
| 👥 **人数上限** | 32 |
| 🛡 **反作弊** | SMAC Ultra |
| ⏰ **夜间重启** | 德黑兰时间 凌晨 5:00 |

> **无需 VPN** — 直接在控制台输入：`connect 147.185.221.215:19303`

---

## ✨ 功能特性

### 🎮 游戏模式

| 模式 | 说明 |
|------|------|
| 🌐 **公共模式** | 经典 — 无尽回合，无友军伤害 |
| 🏆 **竞技模式** | 30 回合，初始资金 $800，回合 1:45，C4 35秒 |
| 💀 **死斗模式** | 3秒复活，满甲，即时战斗 |
| 🔫 **枪王模式** | 每次击杀升级武器 |
| 🎯 **狙击模式** | 仅 AWP + 刀，快速复活 |
| 🔪 **刀战烟雾** | 仅刀和烟雾弹 — 纯技术对决 |

### 🛠 自定义插件 (12个)

- **🛒 简易商店** — 用游戏内金币购买个人皮肤
- **📊 排名系统** — 总排名 + 分武器类别排名
- **🔇 禁言/静音** — 文字和语音禁言，持久化保存
- **🛡 出生保护** — 3秒保护，HUD倒计时
- **🚫 AFK管理** — 自动将挂机玩家移至观察者
- **🎪 趣味模式** — 狙击模式和刀战烟雾模式
- **🔪 刀具选择** — 玩家自选刀具 (M9 / 蝴蝶刀)
- **📢 欢迎与广告** — 欢迎消息、规则、轮播广告
- **🏆 胜利消息** — 金色回合胜利公告
- **💀 死斗复活** — 死斗模式快速复活
- **💬 聊天日志** — 实时聊天记录 + 管理员上线公告
- **📋 管理日志** — 记录所有管理员操作及时间戳

### 📊 Web 管理面板

- 实时仪表盘（玩家、地图、状态、当前模式）
- 地图和游戏模式切换
- 踢出 / 封禁玩家（临时或永久）
- 管理员管理（添加 / 删除）
- 封禁和禁言列表，一键解除
- 实时聊天监控
- 玩家统计和排行榜
- 管理员操作日志
- 服务器重启按钮
- Cookie 会话认证

### ⚙️ 基础设施

- **快速下载** — HTTP 隧道（v34 引擎不支持 TLS）
- **SMAC 反作弊** — 多层防护
- **Tickrate 100** — 流畅游戏体验
- **Metamod + SourceMod** — 插件框架
- **自动备份** — 每 12 小时备份插件数据
- **夜间重启** — 凌晨 5:00 自动重启并通知玩家

---

## 📁 项目结构

```
├── plugins/
│   ├── scripting/          # SourcePawn 源代码 (.sp)
│   └── compiled/           # 编译后的插件 (.smx)
├── configs/
│   ├── gamemodes/          # 游戏模式配置文件
│   └── sourcemod/          # SourceMod 配置
├── panel/
│   ├── panel.py            # Web 管理面板 (Python)
│   └── web/                # 面板界面 (HTML/CSS/JS)
├── scripts/
│   ├── backup_plugin_data.sh   # 自动备份脚本
│   ├── nightly_restart.sh      # 夜间重启脚本
│   └── fastdl_watch.py         # 快速下载监控
└── docs/
    └── INSTALL.md          # 完整安装指南
```

---

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/armadgarsone2/cssv34-server.git
cd cssv34-server

# 安装插件
cp plugins/compiled/*.smx /path/to/cstrike/addons/sourcemod/plugins/

# 安装配置
cp configs/gamemodes/*.cfg /path/to/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /path/to/cstrike/addons/sourcemod/configs/

# 安装面板
cp panel/panel.py /path/to/cssserver/
cp -r panel/web /path/to/cssserver/

# 重启服务器
systemctl restart css34
```

📖 **完整指南：** [docs/INSTALL.md](docs/INSTALL.md)

---

## 🎮 玩家命令

| 命令 | 说明 |
|------|------|
| `!shop` | 打开皮肤商店 |
| `!rank` | 查看你的排名 |
| `!top` | 排行榜（总排名） |
| `!top sniper` | 狙击手排行榜 |
| `!top rifle` | 步枪手排行榜 |
| `!top knife` | 刀杀排行榜 |
| `!knife` | 选择刀具 |
| `!rules` | 服务器规则 |
| `!credits` | 查看金币余额 |

---

## 🛠 管理员命令

| 命令 | 说明 |
|------|------|
| `sm_gag <player> [min] [reason]` | 文字禁言 |
| `sm_mute <player> [min]` | 语音静音 |
| `sm_ungag / sm_unmute <player>` | 解除禁言/静音 |
| `sm_gaglist` | 查看活跃的禁言列表 |
| `sm_dm 0/1` | 开关死斗复活 |
| `sm_adminlog` | 查看最近的管理员操作 |

---

## 📸 已安装皮肤

**枪械：** AK-47 Neon · AK-47 Hardened · AWP Creeper · Desert Eagle Gold · M4A1 NeoNoir
**刀具：** M9 Bayonet · Butterfly Knife
**投掷物：** HE · Smoke · Flashbang

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

<div align="center">

### 🤖 由 AI 构建

本项目 — 架构设计、SourcePawn 插件开发、Web 面板工程、
游戏模式配置和文档 — 全部由人工智能从零开始创建。

---

**⭐ 如果这个项目帮到了你，别忘了给仓库点个 Star！ ⭐**

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>
