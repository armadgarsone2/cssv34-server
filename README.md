<div align="center">

# 🎮 Sefidan CSS v34 Server

### A complete Counter-Strike: Source v34 server — plugins, web panel, gamemodes & more

[![Stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=social)](https://github.com/armadgarsone2/cssv34-server/stargazers)
[![SourceMod](https://img.shields.io/badge/SourceMod-1.7.3-blue)](https://www.sourcemod.net/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Made with AI](https://img.shields.io/badge/Made%20with-AI-purple)](#-built-with-ai)

⭐ **If you find this project useful, please give it a star!** ⭐
It takes 2 seconds and helps others discover it.

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?label=Star%20this%20repo&style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>

---

## ✨ Features

### 🎮 Gamemodes

| Mode | Description |
|------|-------------|
| 🌐 **Public** | Classic — endless rounds, no friendly fire |
| 🏆 **Competitive** | 30 rounds, $800 start money, 1:45 rounds, 35s C4 |
| 💀 **Deathmatch** | 3s respawn, full armor, instant action |
| 🔫 **GunGame** | Weapon upgrades with every kill |
| 🎯 **Sniper** | AWP + knife only, fast respawn |
| 🔪 **Knife+Smoke** | Knife and smokes only — pure skill |

### 🛠 Custom Plugins (12)

- **🛒 Simple Shop** — Buy personal skins with in-game credits
- **📊 Rank System** — Overall + per-weapon-class rankings
- **🔇 Gag/Mute** — Persistent text/voice mutes
- **🛡 Spawn Protect** — 3s protection with HUD countdown
- ** AFK Manager** — Auto-move idle players to spectators
- **🎪 Fun Modes** — Sniper & Knife+Smoke modes
- **🔪 Knife Selector** — Per-player knife choice (M9 / Butterfly)
- **📢 Welcome & Ads** — Welcome message, rules, rotating ads
- **🏆 Win Message** — Golden round-win announcement
- **💀 DM Respawn** — Quick respawn for deathmatch modes
- **💬 Chat Log** — Live chat logging + admin join announcements
- **📋 Admin Log** — Every admin action recorded with timestamps

### 📊 Web Admin Panel

- Live dashboard (players, map, status, active gamemode)
- Map & gamemode switching
- Kick / ban players (temporary or permanent)
- Admin management (add / remove)
- Ban & gag lists with one-click removal
- Live chat monitor
- Player stats & leaderboards
- Admin action log
- Server restart button
- Per-session cookie authentication

### ⚙️ Infrastructure

- **Fast Download** — HTTP tunnel (v34 engine has no TLS support)
- **SMAC Anti-Cheat** — Multi-component protection
- **Tickrate 100** — Smooth gameplay
- **Metamod + SourceMod** — Plugin framework
- **Auto Backup** — Plugin data backed up every 12 hours
- **Nightly Restart** — Automatic restart at 05:00 with player warnings

---

## 📁 Project Structure

```
├── plugins/
│   ├── scripting/          # SourcePawn source code (.sp)
│   └── compiled/           # Compiled plugins (.smx)
├── configs/
│   ├── gamemodes/          # Gamemode config files
│   └── sourcemod/          # SourceMod configs
├── panel/
│   ├── panel.py            # Web admin panel (Python)
│   └── web/                # Panel UI (HTML/CSS/JS)
├── scripts/
│   ├── backup_plugin_data.sh   # Auto-backup script
│   ├── nightly_restart.sh      # Nightly restart script
│   └── fastdl_watch.py         # Fast download watchdog
└── docs/
    └── INSTALL.md          # Full installation guide
```

---

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/armadgarsone2/cssv34-server.git
cd cssv34-server

# Install plugins
cp plugins/compiled/*.smx /path/to/cstrike/addons/sourcemod/plugins/

# Install configs
cp configs/gamemodes/*.cfg /path/to/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /path/to/cstrike/addons/sourcemod/configs/

# Install panel
cp panel/panel.py /path/to/cssserver/
cp -r panel/web /path/to/cssserver/

# Restart server
systemctl restart css34
```

📖 **Full guide:** [docs/INSTALL.md](docs/INSTALL.md)

---

## 🎮 Player Commands

| Command | Description |
|---------|-------------|
| `!shop` | Open the skin shop |
| `!rank` | View your ranking |
| `!top` | Top players (overall) |
| `!top sniper` | Top AWP players |
| `!top rifle` | Top rifle players |
| `!top knife` | Top knife killers |
| `!knife` | Choose your knife |
| `!rules` | Server rules |
| `!credits` | Check your balance |

---

## 🛠 Admin Commands

| Command | Description |
|---------|-------------|
| `sm_gag <player> [min] [reason]` | Gag text chat |
| `sm_mute <player> [min]` | Mute voice |
| `sm_ungag / sm_unmute <player>` | Remove gag/mute |
| `sm_gaglist` | List active gags |
| `sm_dm 0/1` | Toggle deathmatch respawn |
| `sm_adminlog` | Show recent admin actions |

---

## 📸 Installed Skins

**Guns:** AK-47 Neon · AK-47 Hardened · AWP Creeper · Desert Eagle Gold · M4A1 NeoNoir
**Knives:** M9 Bayonet · Butterfly Knife
**Nades:** HE Grenade · Smoke Grenade · Flashbang

---

## 🤝 Contributing

Feel free to open issues or submit pull requests!

---

<div align="center">

### 🤖 Built with AI

This entire project — architecture design, SourcePawn plugin development,
web panel engineering, gamemode configuration, and documentation — was
created from scratch with the assistance of artificial intelligence.

---

**⭐ Don't forget to star the repo if this helped you! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>
