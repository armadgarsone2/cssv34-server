<div align="center">

# 🎮 سرور CSS وی۳۴ سفیدان

### سرور کامل Counter-Strike: Source v34 — پلاگین‌ها، پنل وب، گیم‌مودها و بیشتر

**🌐 زبان‌ها:** [English](README.md) · [فارسی](README.fa.md) · [中文](README.zh-CN.md) · [العربية](README.ar.md) · [Русский](README.ru.md)

[![Stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=social)](https://github.com/armadgarsone2/cssv34-server/stargazers)
[![SourceMod](https://img.shields.io/badge/SourceMod-1.7.3-blue)](https://www.sourcemod.net/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

⭐ **اگه این پروژه بهدردت خورد، لطفاً ستاره بزن!** ⭐
فقط ۲ ثانیه طول می‌کشه و به بقیه کمک می‌کنه پیداش کنن.

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?label=این پروژه را ستاره کن&style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>

---

## 🌐 سرور زنده ما

| | |
|---|---|
| 🎮 **اتصال** | `147.185.221.215:19303` |
| 🖥 **موتور** | CS:S v34 (ClientMod) |
| ⚡ **تیک‌ریت** | ۱۰۰ |
| 👥 **ظرفیت** | ۳۲ نفر |
| 🛡 **آنتی‌چیت** | SMAC Ultra |
| ⏰ **ری‌استارت شبانه** | ساعت ۵ صبح به وقت تهران |

> **نیازی به فیلترشکن نیست** — مستقیم وصل شو: `connect 147.185.221.215:19303`

---

## ✨ امکانات

### 🎮 گیم‌مودها

| حالت | توضیح |
|------|-------|
| 🌐 **پابلیک** | کلاسیک — راند بی‌انتها، بدون فرندلی‌فایر |
| 🏆 **کامپتیو** | ۳۰ راند، پول اول ۸۰۰ دلار، راند ۱:۴۵، سی۴: ۳۵ ثانیه |
| 💀 **دث‌مچ** | ری‌اسپاون ۳ ثانیه‌ای، زره کامل، اکشن فوری |
| 🔫 **گان‌گیم** | با هر کشتن اسلحه ارتقا پیدا می‌کند |
| 🎯 **اسنایپر** | فقط AWP + چاقو، ری‌اسپاون سریع |
| 🔪 **چاقو دودی** | فقط چاقو و دودی — مهارت خالص |

### 🛠 پلاگین‌های سفارشی (۱۲)

- **🛒 ساده شاپ** — خرید اسکین شخصی با سکه درون‌بازی
- **📊 سیستم رتبه‌بندی** — رتبه کلی + تفکیکی سلاح
- **🔇 گگ/مت** — سکوت متنی و صوتی با ماندگاری
- **🛡 محافظت ری‌اسپاون** — ۳ ثانیه محافظت با شمارش معکوس
- **🚫 مدیریت AFK** — انتقال خودکار بازیکنان بی‌حرکت
- **🎪 گیم‌مودهای فان** — حالت‌های اسنایپر و چاقو دودی
- **🔪 انتخاب چاقو** — انتخاب چاقوی شخصی (M9 / پروانه‌ای)
- **📢 خوش‌آمد و تبلیغات** — پیام خوش‌آمد، قوانین، تبلیغات چرخشی
- **🏆 پیام برد** — اعلام طلایی برد راند
- **💀 ری‌اسپاون دث‌مچ** — ری‌اسپاون سریع برای حالت دث‌مچ
- **💬 لاگ چت** — ثبت زنده چت + اعلام ورود ادمین
- **📋 لاگ ادمین** — ثبت همه اکشن‌های ادمین با تاریخ و ساعت

### 📊 پنل مدیریت وب

- داشبورد زنده (بازیکنان، مپ، وضعیت، گیم‌مود فعال)
- تعویض مپ و گیم‌مود
- کیک / بن بازیکنان (مدت‌دار یا دائمی)
- مدیریت ادمین‌ها (افزودن / حذف)
- لیست بن‌ها و گگ‌ها با حذف یک‌کلیکی
- مانیتور چت زنده
- آمار و برترین‌های بازیکنان
- لاگ اکشن‌های ادمین
- دکمه ری‌استارت سرور
- احراز هویت با کوکی نشست

### ⚙️ زیرساخت

- **فست‌دانلود** — تونل HTTP (موتور v34 از TLS پشتیبانی نمی‌کند)
- **آنتی‌چیت SMAC** — محافظت چندلایه
- **تیک‌ریت ۱۰۰** — گیم‌پلی روان
- **Metamod + SourceMod** — فریم‌ورک پلاگین‌ها
- **بکاپ خودکار** — بکاپ داده‌های پلاگین هر ۱۲ ساعت
- **ری‌استارت شبانه** — ری‌استارت خودکار ساعت ۵ صبح با اخطار به بازیکنان

---

## 📁 ساختار پروژه

```
├── plugins/
│   ├── scripting/          # کد منبع پلاگین‌ها (.sp)
│   └── compiled/           # پلاگین‌های کامپایل‌شده (.smx)
├── configs/
│   ├── gamemodes/          # کانفیگ گیم‌مودها
│   └── sourcemod/          # کانفیگ سورس‌ماد
├── panel/
│   ├── panel.py            # پنل مدیریت وب (پایتون)
│   └── web/                # رابط کاربری پنل
├── scripts/
│   ├── backup_plugin_data.sh   # اسکریپت بکاپ خودکار
│   ├── nightly_restart.sh      # اسکریپت ری‌استارت شبانه
│   └── fastdl_watch.py         # واچ‌داگ فست‌دانلود
└── docs/
    └── INSTALL.md          # راهنمای کامل نصب
```

---

## 🚀 نصب سریع

```bash
# کلون کردن
git clone https://github.com/armadgarsone2/cssv34-server.git
cd cssv34-server

# نصب پلاگین‌ها
cp plugins/compiled/*.smx /path/to/cstrike/addons/sourcemod/plugins/

# نصب کانفیگ‌ها
cp configs/gamemodes/*.cfg /path/to/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /path/to/cstrike/addons/sourcemod/configs/

# نصب پنل
cp panel/panel.py /path/to/cssserver/
cp -r panel/web /path/to/cssserver/

# ری‌استارت سرور
systemctl restart css34
```

📖 **راهنمای کامل:** [docs/INSTALL.md](docs/INSTALL.md)

---

## 🎮 دستورات بازیکن

| دستور | توضیح |
|-------|-------|
| `!shop` | باز کردن فروشگاه اسکین |
| `!rank` | مشاهده رتبه شما |
| `!top` | برترین‌ها (کلی) |
| `!top sniper` | برترین اسنایپرها |
| `!top rifle` | برترین رایفل‌ها |
| `!top knife` | برترین چاقوکش‌ها |
| `!knife` | انتخاب چاقو |
| `!rules` | قوانین سرور |
| `!credits` | بررسی موجودی سکه |

---

## 🛠 دستورات ادمین

| دستور | توضیح |
|-------|-------|
| `sm_gag <player> [min] [reason]` | گگ متنی |
| `sm_mute <player> [min]` | مت صوتی |
| `sm_ungag / sm_unmute <player>` | برداشتن گگ/مت |
| `sm_gaglist` | لیست گگ/مت‌های فعال |
| `sm_dm 0/1` | فعال/غیرفعال ری‌اسپاون دث‌مچ |
| `sm_adminlog` | نمایش آخرین اکشن‌های ادمین |

---

## 📸 اسکین‌های نصب‌شده

**گان‌ها:** AK-47 Neon · AK-47 Hardened · AWP Creeper · Desert Eagle Gold · M4A1 NeoNoir
**چاقوها:** M9 Bayonet · Butterfly Knife
**نارنجک‌ها:** HE · Smoke · Flashbang

---

## 🤝 مشارکت

خوشحال می‌شیم ایشو باز کنی یا پول ریکوئست بفرستی!

---

<div align="center">

### 🤖 ساخته‌شده با هوش مصنوعی

این پروژه به‌طور کامل — طراحی معماری، توسعه پلاگین‌های SourcePawn،
مهندسی پنل وب، تنظیمات گیم‌مود و مستندسازی — از صفر با کمک
هوش مصنوعی ساخته شده است.

---

**⭐ فراموش نکن این مخزن را ستاره کنی اگه کمکت کرد! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>
