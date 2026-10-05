# 📖 راهنمای نصب کامل

## ۱. آماده‌سازی سرور بازی

### نصب Source Engine Dedicated Server

```bash
# نصب SteamCMD
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf steamcmd_linux.tar.gz

# نصب سرور CS:S
./steamcmd.sh +login anonymous +force_install_dir /home/cssserver +app_update 232330 validate +quit
```

### نصب Metamod:Source

```bash
cd /home/cssserver/cstrike/addons
wget https://mms.alliedmods.net/mmsdrop/1.12/mms-1.12.0-git1297-linux.tar.gz
tar -xzf mms-1.12.0-git1297-linux.tar.gz
```

### نصب SourceMod

```bash
cd /home/cssserver/cstrike/addons
wget https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7210-linux.tar.gz
tar -xzf sourcemod-1.12.0-git7210-linux.tar.gz
```

---

## ۲. نصب پلاگین‌ها

```bash
# کپی پلاگین‌های کامپایل‌شده
cp plugins/compiled/*.smx /home/cssserver/cstrike/addons/sourcemod/plugins/

# کپی تنظیمات
cp configs/gamemodes/*.cfg /home/cssserver/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /home/cssserver/cstrike/addons/sourcemod/configs/
```

---

## ۳. نصب پنل مدیریت

```bash
# کپی فایل‌های پنل
cp panel/panel.py /root/cssserver/
cp -r panel/web /root/cssserver/

# تنظیم مجوزها
chmod +x /root/cssserver/panel.py

# ساخت سرویس systemd
cat > /etc/systemd/system/css34-panel.service << 'EOF'
[Unit]
Description=CSS v34 Web Panel
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /root/cssserver/panel.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable css34-panel
systemctl start css34-panel
```

---

## ۴. تنظیمات مهم

### server.cfg

```cfg
// رمز RCON (تغییر دهید!)
rcon_password "YOUR_STRONG_PASSWORD"

// نام سرور
hostname "Your Server Name | v34"

// تیک‌ریت
sys_ticrate 100
pingboost 3

// فست‌دانلود
sv_downloadurl "http://your-fastdl-url/"
```

### admins_simple.ini

```ini
// ادمین‌ها
"STEAM_0:0:12345678" "99:z"    // دسترسی کامل
"STEAM_0:1:87654321" "bcdef"   // دسترسی متوسط
```

---

## ۵. فست‌دانلود (اختیاری)

```bash
# نصب bore
wget https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz
tar -xzf bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz

# اجرا
./bore local 8090 --to bore.pub
```

---

## ۶. راه‌اندازی نهایی

```bash
# ری‌استارت سرور بازی
systemctl restart css34

# بررسی لاگ‌ها
tail -f /root/cssserver/console_history.log
```

---

## ❗ عیب‌یابی

### پلاگین لود نمی‌شود
```bash
# بررسی نسخه SourceMod
sm version

# بررسی پلاگین‌ها
sm plugins list
```

### پنل باز نمی‌شود
```bash
# بررسی سرویس
systemctl status css34-panel

# بررسی پورت
ss -tlnp | grep 8081
```

### فست‌دانلود کار نمی‌کند
```bash
# بررسی تونل
systemctl status css34-fastdl-bore

# تست محلی
curl http://127.0.0.1:8090/
```

---

## 📞 پشتیبانی

مشکلی داشتی؟ [Issues](../../issues) بزن یا در گروه تلگرام بپرس.

---

**ساخته‌شده با هوش مصنوعی | ۲۰۲۶**
