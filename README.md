# Counter-Strike Source v34 No-Steam Server with ClientMod Support

Complete guide and configuration files for setting up and running a stable CSS v34 dedicated server with **ClientMod** (`https://clientmod.ru/`) compatibility, completely bypassing Steam validation errors (`STEAM validation rejected`).

---

## 🛠️ Features
- **No-Steam Support:** Works with non-steam clients and ClientMod.
- **ReviveEmu Integration:** Custom-compiled 32-bit `libsteamvalidateuseridtickets.so`.
- **Engine Patching:** Patched `engine_i486.so` to skip Steam authentication hangs (`JNE` -> `JMP`).
- **Systemd Service:** Automated service management with auto-restart.
- **Anti-Cheat Cleanup:** Removed conflicting SMAC anti-cheat extensions that cause v34 crashes.
- **Firewall Isolation:** Blocked outbound Steam auth traffic via `iptables` to prevent hangs.

---

## 🚀 Quick Setup & Installation

### 1. Prerequisites
```bash
apt-get install -y cmake gcc-multilib g++-multilib iptables-persistent
```

### 2. Build ReviveEmu (32-bit)
```bash
cd /tmp
git clone --depth 1 https://github.com/NicknineTheEagle/ReviveEmu.git
cd ReviveEmu/Steam/steam
cmake -B build -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32"
cmake --build build -j$(nproc)
```

### 3. Deploy Binaries & Patches
- Copy ReviveEmu library:
  ```bash
  cp /tmp/ReviveEmu/Steam/steam/build/libsteamvalidateuseridtickets.so \
    /root/cssv34/csds-v34-2009-08-26/bin/libsteamvalidateuseridtickets_i486.so
  ```
- Patch engine binary to skip validation:
  ```bash
  python3 /root/cssv34-server/fixes/patch_engine_nosteam.py \
    /root/cssv34/csds-v34-2009-08-26/bin/engine_i486.so
  ```

### 4. Configure Firewall Rules
```bash
iptables -I OUTPUT -p tcp --dport 27015:27050 ! -o lo -j REJECT --reject-with tcp-reset
netfilter-persistent save
```

### 5. Setup Systemd Service
Create `/etc/systemd/system/css34.service`:
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

Enable and start:
```bash
systemctl daemon-reload
systemctl enable css34
systemctl start css34
```

---

## 📂 Repository Structure
- `fixes/patch_engine_nosteam.py`: Python script to patch `engine_i486.so`.
- `scripts/css34.service`: Systemd service unit file.
- `cstrike/`: Server configuration, maps, and plugins (SourceMod, GunGame).

---

## 🔍 Troubleshooting
- **STEAM validation rejected:** Ensure both ReviveEmu library and engine patch are applied correctly.
- **Server Hangs on Startup:** Check `iptables` rules blocking external Steam master server queries.
- **Crash on Start:** Remove any incompatible SourceMod anti-cheat extensions (`*smac*`).
