# Counter-Strike Source v34 No-Steam Server with ClientMod Support

**Complete production guide** for running a stable CSS v34 (protocol 48, 2009 build) dedicated server on Linux with **ClientMod** (`https://clientmod.ru/`) compatibility, fully bypassing Steam validation (`STEAM validation rejected`) and startup hangs.

---

## 🎯 What This Solves

| Problem | Solution |
|---------|----------|
| `STEAM validation rejected` on client connect | ReviveEmu `libsteamvalidateuseridtickets_i486.so` + engine binary patch |
| Server hangs on startup (Steam master server queries) | `iptables` REJECT outbound Steam ports 27015-27050 |
| SMAC anti-cheat crashes on v34 engine | Complete removal of all `*smac*` extensions |
| 32-bit library mismatches | Compile ReviveEmu with `-m32` flags |
| ClientMod clients cannot join | Protocol 48 + RevEmu validation + `-insecure` flag |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS (Ubuntu 24.04)                       │
│  ┌──────────────────┐    ┌──────────────────────────────┐  │
│  │  systemd: css34  │───▶│  srcds_i486 (v34 engine)     │  │
│  │  auto-restart    │    │  -game cstrike               │  │
│  │  5s restart delay│    │  -insecure -nobreakpad       │  │
│  └────────┬─────────┘    │  +ip 0.0.0.0 +port 27015     │  │
│           │              └──────────────┬───────────────┘  │
│           │                             │                   │
│           ▼                             ▼                   │
│  ┌──────────────────┐    ┌──────────────────────────────┐  │
│  │  iptables        │    │  Binaries (patched)          │  │
│  │  REJECT OUT      │    │  • engine_i486.so (JNE→JMP)  │  │
│  │  TCP 27015-27050 │    │  • libsteamvalidateuserid    │  │
│  │  ! -o lo         │    │    tickets_i486.so (Revive)  │  │
│  └──────────────────┘    └──────────────────────────────┘  │
│           │                             │                   │
│           ▼                             ▼                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  SourceMod 1.7.3 (CSS34 fork) + GunGame + Metamod    │  │
│  │  NO SMAC (removed — crashes v34)                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

```bash
# Required packages
apt-get update && apt-get install -y \
  cmake gcc-multilib g++-multilib \
  iptables-persistent \
  git tar gzip
```

---

## 🔧 Step-by-Step Setup

### 1. Server Files & Directory Structure

```
/root/cssv34/
├── csds-v34-2009-08-26/          # Main server installation
│   ├── bin/
│   │   ├── engine_i486.so                 # PATCHED (validation skip)
│   │   ├── engine_i486.so.orig            # Original backup
│   │   ├── libsteamvalidateuseridtickets_i486.so  # ReviveEmu build
│   │   ├── libsteamvalidateuseridtickets_i486.so.valve_original  # Valve backup
│   │   └── srcds_i486
│   ├── cstrike/
│   │   ├── cfg/server.cfg
│   │   ├── addons/
│   │   │   ├── metamod/                   # Metamod 1.10.7
│   │   │   └── sourcemod/                 # SourceMod 1.7.3 CSS34
│   └── platform/
└── cssv34-server/
    ├── fixes/
    │   ├── patch_engine_nosteam.py        # Engine binary patcher
    │   └── fix_hang.sh                    # iptables + SMAC cleanup
    └── scripts/
        └── css34.service                  # systemd unit
```

### 2. Build ReviveEmu (32-bit)

```bash
cd /tmp
git clone --depth 1 https://github.com/NicknineTheEagle/ReviveEmu.git
cd ReviveEmu/Steam/steam
cmake -B build -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"
cmake --build build -j$(nproc)

# Deploy to server
cp build/libsteamvalidateuseridtickets.so \
  /root/cssv34/csds-v34-2009-08-26/bin/libsteamvalidateuseridtickets_i486.so
```

**Why ReviveEmu?**  
Valve's original `libsteamvalidateuseridtickets` requires live Steam backend. ReviveEmu implements the same interface locally — validates tickets without Steam. ClientMod expects this exact interface.

### 3. Patch Engine Binary (Skip Validation Check)

```bash
python3 /root/cssv34-server/fixes/patch_engine_nosteam.py \
  /root/cssv34/csds-v34-2009-08-26/bin/engine_i486.so
```

**What it does:**  
Finds the `JNE` (Jump if Not Equal) instruction at the Steam ticket validation check and replaces it with `JMP` (unconditional jump) + `NOP`. This makes the engine **always accept** the ticket validation result, effectively skipping the Steam auth handshake.

```
Original:  0f 85 85 fe ff ff    JNE  <validation_failed>
Patched:   e9 86 fe ff ff 90    JMP  <validation_success> + NOP
```

**Verification:** `md5sum engine_i486.so` → `ffaf4936002709beb9848eae3a015468`

### 4. Block Steam Master Server Traffic (Prevents Hangs)

```bash
# Reject outbound Steam auth/query ports (non-loopback only)
iptables -I OUTPUT -p tcp --dport 27015:27050 ! -o lo -j REJECT --reject-with tcp-reset

# Persist across reboots
netfilter-persistent save
```

**Why REJECT not DROP?**  
`REJECT --reject-with tcp-reset` sends TCP RST immediately — engine fails fast instead of hanging on `SYN_SENT` timeout.

### 5. Remove SMAC Anti-Cheat (Crashes v34)

```bash
find /root/cssv34/csds-v34-2009-08-26/cstrike/addons/sourcemod -iname "*smac*" -delete
```

**Root cause:** SMAC's `Ultr@Tools.ext.so` and SMAC core extensions use engine interfaces that don't exist in v34 (2009). Causes `SIGSEGV` on map change or player connect.

### 6. Install systemd Service

```bash
cp /root/cssv34-server/scripts/css34.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable css34
systemctl start css34
```

**Service unit (`/etc/systemd/system/css34.service`):**
```ini
[Unit]
Description=CSS v34 No-Steam Dedicated Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/cssv34/csds-v34-2009-08-26
Environment="LD_LIBRARY_PATH=/root/cssv34/csds-v34-2009-08-26:/root/cssv34/csds-v34-2009-08-26/bin:/root/cssv34/csds-v34-2009-08-26/platform/bin"
ExecStart=/root/cssv34/csds-v34-2009-08-26/srcds_i486 -game cstrike -console -usercon -nobreakpad -insecure +ip 0.0.0.0 +port 27015 +maxplayers 16 +map de_dust2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Key flags explained:**
| Flag | Purpose |
|------|---------|
| `-insecure` | Disable VAC/Steam auth (required for No-Steam) |
| `-nobreakpad` | Disable crash reporter (reduces overhead) |
| `-usercon` | Enable RCON from console |
| `-console` | Show console output in systemd logs |

### 7. Verify Server is Running

```bash
# Check service status
systemctl status css34 --no-pager

# Verify port listening
ss -tlnp | grep :27015
# LISTEN  0  2  0.0.0.0:27015  0.0.0.0:*  users:(("srcds_i486",pid=XXXXX,fd=7))

# Watch live logs
journalctl -u css34 -f
```

---

## 🔌 ClientMod Connection

ClientMod (`https://clientmod.ru/`) clients connect **without any extra config** because:
1. Server runs **protocol 48** (v34 native)
2. `libsteamvalidateuseridtickets_i486.so` validates RevEmu tickets locally
3. Engine patch skips the "is this a valid Steam ticket?" check
4. `-insecure` tells engine not to verify with Steam backend
5. iptables blocks outbound Steam traffic so server never hangs waiting for master server response

**Client requirements:** Clean CSS v34 No-Steam + ClientMod installer. No RevEmu/SteamFix needed client-side.

---

## 📦 Installed Plugins (SourceMod)

| Plugin | Status | Notes |
|--------|--------|-------|
| `sourcemod_mm` (Metamod) | ✅ Loaded | 1.10.7 + SM 1.7.3 CSS34 |
| `gungame.smx` | ✅ Loaded | Arena/Deathmatch modes |
| `admin-help.smx` | ✅ Loaded | Core admin |
| `basetriggers.smx` | ✅ Loaded | Map triggers |
| `funcommands.smx` | ✅ Loaded | Slay, slap, etc. |
| `nextmap.smx` | ✅ Loaded | Map voting |
| **SMAC (all)** | ❌ **Removed** | Crashes v34 engine |

**Metamod config** (`cstrike/addons/metamod/metaplugins.ini`):
```
addons/sourcemod/bin/sourcemod_mm
```

---

## 🛡️ Server Configuration Highlights

`cstrike/cfg/server.cfg`:
```cfg
hostname "CSS v34 No-Steam | ClientMod Ready"
rcon_password "CHANGE_ME"
sv_password ""                    // Public server
sv_lan 0
sv_region 3                       // Europe
sv_contact "admin@example.com"

mp_timelimit 20
mp_maxrounds 0
mp_winlimit 0
mp_freezetime 6
mp_roundtime 2
mp_c4timer 35

sv_cheats 0
sv_consistency 1
sv_pure 0                         // Allow custom models/sounds
sv_allowdownload 1
sv_allowupload 1
sv_downloadurl ""                 // Set to FastDL if available

log on
sv_logbans 1
sv_logecho 1
sv_logfile 1
sv_log_onefile 0
```

**Tickrate:** 100 (default for srcds v34, set via `fps_max 100` in launch or `sys_ticrate 100` in cfg)

---

## 🔄 Automated Backups (Every 6 Hours)

Cron job `hermes-full-backup-6h` runs `/root/.hermes/scripts/lean_backup_push.py`:

1. Creates tarball of **essential files only** (excludes maps/sounds/models/cache)
2. Splits into 40MB parts if >40MB (GitHub 100MB limit)
3. Force-pushes to `armadgarsone2/hermes-backup` repo
4. Keeps last 12 backups via git history

**Backup contents:**
- Hermes: skills, memories, config, scripts
- CSS v34: patched binaries, `server.cfg`, SourceMod configs/plugins, Metamod
- cssv34-server: fix scripts, systemd unit

**Restore:**
```bash
cd /root/hermes-backup
cat backup_part_* > lean_backup.tar.gz
tar -xzf lean_backup.tar.gz -C /
systemctl restart css34
```

---

## 🐛 Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `STEAM validation rejected` | Engine patch missing or wrong lib | Re-run patch script + verify ReviveEmu lib exists |
| Server hangs on "Validating Steam UserID Ticket" | iptables not blocking Steam ports | `iptables -L OUTPUT -n -v` verify rule |
| Crash on map change | SMAC or incompatible extension | `find . -iname "*smac*" -delete` |
| `engine_i486.so: cannot open shared object` | LD_LIBRARY_PATH missing | Check systemd `Environment=` line |
| ClientMod: "Server uses different protocol" | Wrong engine build | Must use csds-v34-2009-08-26 (protocol 48) |
| Git push fails: "file > 100MB" | Backup too large | Script auto-splits; verify parts < 50MB |

---

## 📂 Key Files Reference

| File | Purpose |
|------|---------|
| `/etc/systemd/system/css34.service` | systemd unit |
| `/root/cssv34/csds-v34-2009-08-26/bin/engine_i486.so` | Patched engine (JNE→JMP) |
| `/root/cssv34/csds-v34-2009-08-26/bin/libsteamvalidateuseridtickets_i486.so` | ReviveEmu validation lib |
| `/root/cssv34-server/fixes/patch_engine_nosteam.py` | Binary patcher |
| `/root/cssv34-server/fixes/fix_hang.sh` | iptables + SMAC cleanup |
| `/root/.hermes/scripts/lean_backup_push.py` | Automated backup script |
| `/root/.hermes/skills/cssv34-nosteam-setup` | Hermes skill for re-deployment |

---

## ✅ Verification Checklist

- [ ] `systemctl status css34` → `active (running)`
- [ ] `ss -tlnp | grep :27015` → LISTEN on 0.0.0.0:27015
- [ ] `journalctl -u css34 -n 20` → No "STEAM validation" errors
- [ ] ClientMod client connects → joins game, no validation error
- [ ] `iptables -L OUTPUT -n` → REJECT rule for 27015-27050 present
- [ ] `ls /root/cssv34/csds-v34-2009-08-26/cstrike/addons/sourcemod/plugins/ | grep -i smac` → empty
- [ ] GitHub backup repo has latest `backup_part_*` files < 50MB each

---

## 📜 License & Credits

- **ReviveEmu** by NicknineTheEagle — MIT License
- **SourceMod CSS34 fork** by AlliedModders + community
- **Metamod:Source** — GPL
- **Counter-Strike Source v34** — Valve (2009), used under No-Steam/educational context
- **ClientMod** — https://clientmod.ru/

---

## 🔗 Related Repositories

- **Backup repo:** https://github.com/armadgarsone2/hermes-backup
- **Server config repo:** https://github.com/armadgarsone2/cssv34-server
- **ReviveEmu:** https://github.com/NicknineTheEagle/ReviveEmu
- **ClientMod:** https://clientmod.ru/

---

*Last updated: 2026-10-14 | Server IP: 172.31.12.104:27015 | Tickrate: 100 | Maxplayers: 16*
