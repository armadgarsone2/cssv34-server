# 🎮 Sefidan CSS v34 Server

> **Counter-Strike: Source v34** — سرور کامل با پلاگین‌های سفارشی، پنل مدیریت وب، و سیستم‌های پیشرفته بازی

[![](https://img.shields.io/badge/SourceMod-1.7.3-blue)](https://www.sourcemod.net/)
[![](https://img.shields.io/badge/Engine-v34-orange)]()
[![](https://img.shields.io/badge/AI-Built-purple)]()
[![](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## ✨ امکانات

### 🎮 گیم‌مودها
| حالت | توضیح |
|------|-------|
| 🌐 پابلیک | کلاسیک — راند بی‌انتها |
| 🏆 کامپتیو | ۳۰ راند، پول اول ۸۰۰، اقتصاد صعودی |
| 💀 دث‌مچ | ری‌اسپاون ۳ ثانیه + زره کامل |
| 🔫 گان‌گیم | با هر کشتن اسلحه عوض می‌شود |
| 🎯 اسنایپر | فقط AWP + چاقو، ری‌اسپاون سریع |
| 🔪 چاقو دودی | فقط چاقو + دودی، کمپ و فان |

### 🛠 پلاگین‌های سفارشی
- **Shop Simple** — فروشگاه اسکین شخصی با اعمال در پایان راند
- **Rank System** — رتبه‌بندی کلی + تفکیکی (اسنایپر/رایفل/کلت/چاقو)
- **Gag Mute** — گگ/مت مدت‌دار با ماندگاری بعد از ری‌استارت
- **Spawn Protect** — ۳ ثانیه محافظت ری‌اسپاون با HUD شمارش معکوس
- **AFK Manager** — انتقال خودکار بی‌حرکت‌ها به تماشاگر
- **Fun Modes** — حالت‌های اسنایپر و چاقو دودی
- **Knife Selector** — انتخاب چاقو (M9/پروانه‌ای) per-player
- **Welcome Ads** — خوش‌آمد + قوانین ۱۲ بندی + تبلیغات چرخشی
- **Win Message** — پیام طلایی برد راند
- **DM Respawn** — ری‌اسپاون سریع برای حالت دث‌مچ
- **Chat Log** — لاگ چت + اعلام ورود ادمین

### 📊 پنل مدیریت وب
- داشبورد زنده (بازیکنان، مپ، وضعیت)
- تعویض مپ + گیم‌مود
- کیک/بن بازیکن
- مدیریت ادمین‌ها
- لیست بن‌ها + گگ/مت‌ها
- چت زنده بازیکنان
- آمار برترین‌ها
- ری‌استارت سرور

### ⚙️ زیرساخت
- **فست‌دانلود** — HTTP خالص با bore tunnel
- **SMAC** — آنتی‌چیت
- **Tickrate 100** — روان
- **Metamod + SourceMod** — پایه پلاگین‌ها

---

## 📁 ساختار پروژه

```
├── plugins/
│   ├── scripting/          # کد منبع پلاگین‌ها (.sp)
│   └── compiled/           # پلاگین‌های کامپایل‌شده (.smx)
├── configs/
│   ├── gamemodes/          # تنظیمات هر گیم‌مود
│   └── sourcemod/          # تنظیمات SourceMod
├── panel/
│   ├── panel.py            # پنل مدیریت وب (Python)
│   └── web/                # رابط کاربری پنل
├── scripts/
│   ├── fastdl_watch.py     # واچ‌داگ فست‌دانلود
│   └── skinwatch.py        # واچ‌داگ اسکین‌ها
└── docs/
    └── INSTALL.md          # راهنمای نصب
```

---

## 🚀 نصب سریع

### پیش‌نیازها
- Linux (تست‌شده روی Ubuntu 22.04)
- Python 3.8+
- SourceMod 1.7.3
- Metamod:Source

### مراحل نصب

```bash
# 1. کلون کردن مخزن
git clone https://github.com/your-username/cssv34-server.git
cd cssv34-server

# 2. کپی پلاگین‌ها
cp plugins/compiled/*.smx /path/to/cstrike/addons/sourcemod/plugins/

# 3. کپی تنظیمات
cp configs/gamemodes/*.cfg /path/to/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /path/to/cstrike/addons/sourcemod/configs/

# 4. نصب پنل
cp panel/panel.py /path/to/cssserver/
cp -r panel/web /path/to/cssserver/
chmod +x panel.py

# 5. ری‌استارت سرور
systemctl restart css34
```

راهنمای کامل: [docs/INSTALL.md](docs/INSTALL.md)

---

## 🎮 دستورات بازیکن

| دستور | توضیح |
|-------|-------|
| `!shop` | فروشگاه اسکین |
| `!rank` | رتبه شما |
| `!top` | برترین‌ها |
| `!top sniper` | برترین اسنایپرها |
| `!knife` | انتخاب چاقو |
| `!rules` | قوانین سرور |
| `!credits` | موجودی سکه |

---

## 🛠 دستورات ادمین

| دستور | توضیح |
|-------|-------|
| `sm_gag <player> [min] [reason]` | گگ متنی |
| `sm_mute <player> [min]` | مت صوتی |
| `sm_ungag / sm_unmute <player>` | برداشتن گگ/مت |
| `sm_gaglist` | لیست گگ/مت‌ها |
| `sm_dm 0/1` | فعال/غیرفعال دث‌مچ |

---

## 📸 اسکین‌های نصب‌شده

### گان‌ها
- AK-47 Neon / Hardened
- AWP Creeper
- Desert Eagle Gold
- M4A1 NeoNoir

### چاقوها
- M9 Bayonet
- Butterfly Knife

### نارنجک‌ها
- HE Grenade
- Smoke Grenade
- Flashbang

---

## 🤖 ساخته‌شده با هوش مصنوعی

این پروژه **صفر تا صد** با کمک هوش مصنوعی ساخته شده:
- طراحی معماری سرور
- کدنویسی پلاگین‌های SourcePawn
- توسعه پنل مدیریت وب
- تنظیمات گیم‌مودها
- مستندسازی و راهنماها

---

## 📄 لایسنس

این پروژه تحت لایسنس [MIT](LICENSE) منتشر شده است.

---

## 🙏 قدردانی

- [SourceMod](https://www.sourcemod.net/) — فریم‌ورک پلاگین
- [Metamod:Source](https://www.metamodsource.net/) — لایه میانی
- [SMAC](https://github.com/alliedmodders/smac) — آنتی‌چیت
- [playit.gg](https://playit.gg/) — تونل UDP

---

**ساخته‌شده با ❤️ و هوش مصنوعی | Sefidan CSS v34**
