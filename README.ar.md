<div align="center">

# 🎮 سيرفر Sefidan CSS v34

### سيرفر كامل Counter-Strike: Source v34 — الإضافات، لوحة التحكم، أوضاع اللعب والمزيد

**🌐 اللغات:** [English](README.md) · [فارسی](README.fa.md) · [中文](README.zh-CN.md) · [العربية](README.ar.md) · [Русский](README.ru.md)

[![Stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=social)](https://github.com/armadgarsone2/cssv34-server/stargazers)
[![SourceMod](https://img.shields.io/badge/SourceMod-1.7.3-blue)](https://www.sourcemod.net/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

⭐ **إذا كانت هذه المشروع مفيد لك، يرجى إعطاء نجمة!** ⭐
يستغرق الأمر ثانيتين فقط ويساعد الآخرين على اكتشافه.

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?label=أعطِ هذا المشروع نجمة&style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>

---

## 🌐 سيرفرنا المباشر

| | |
|---|---|
| 🎮 **اتصال** | `147.185.221.215:19303` |
| 🖥 **المحرك** | CS:S v34 (ClientMod) |
| ⚡ **Tickrate** | 100 |
| 👥 **السعة** | 32 لاعب |
| 🛡 **مكافحة الغش** | SMAC Ultra |
| ⏰ **إعادة التشغيل الليلية** | 05:00 بتوقيت طهران |

> **لا حاجة لبرنامج VPN** — اتصل مباشرة عبر الكونسول: `connect 147.185.221.215:19303`

---

## ✨ المميزات

### 🎮 أوضاع اللعب

| الوضع | الوصف |
|-------|-------|
| 🌐 **عام** | كلاسيكي — جولات بلا نهاية، بدون إصابة الأصدقاء |
| 🏆 **تنافسي** | 30 جولة، مال ابتدائي 800$، جولة 1:45، C4: 35 ثانية |
| 💀 **ديث ماتش** | إعادة ظهور 3 ثوانٍ، درع كامل، قتال فوري |
| 🔫 **جوجن جيم** | ترقية السلاح مع كل قتل |
| 🎯 **قنّاص** | AWP + سكين فقط، إعادة ظهور سريعة |
| 🔪 **سكين ودخان** | سكين وقناني دخان فقط — مهارة خالصة |

### 🛠 الإضافات المخصصة (12)

- **🛒 متجر بسيط** — شراء أزياء شخصية بالعملات داخل اللعبة
- **📊 نظام الترتيب** — ترتيب عام + ترتيب لكل فئة أسلحة
- **🔇 حظر الكلام/الصوت** — حظر دائم مع حفظ البيانات
- **🛡 حماية الظهور** — 3 ثوانٍ حماية مع عد تنازلي
- **🚫 مدير AFK** — نقل اللاعبين الخاملين تلقائيًا إلى المشاهدين
- **🎪 أوضاع ممتعة** — وضع القنّاص ووضع السكين والدخان
- **🔪 اختيار السكين** — اختيار السكين لكل لاعب (M9 / فراشة)
- **📢 الترحيب والإعلانات** — رسالة ترحيب، قوانين، إعلانات دورية
- **🏆 رسالة الفوز** — إعلان ذهبي لفوز الجولة
- **💀 إعادة ظهور ديث ماتش** — إعادة ظهور سريعة لوضع الديث ماتش
- **💬 سجل الدردشة** — تسجيل مباشر + إعلان دخول المشرفين
- **📋 سجل المشرفين** — تسجيل جميع إجراءات المشرفين مع التوقيت

### 📊 لوحة تحكم الويب

- لوحة معلومات مباشرة (اللاعبون، الخريطة، الحالة، الوضع النشط)
- تبديل الخريطة ووضع اللعب
- طرد / حظر اللاعبين (مؤقت أو دائم)
- إدارة المشرفين (إضافة / حذف)
- قوائم الحظر والحظر مع إزالة بنقرة واحدة
- مراقبة الدردشة المباشرة
- إحصائيات اللاعبين ولوحة المتصدرين
- سجل إجراءات المشرفين
- زر إعادة تشغيل السيرفر
- مصادقة بالكوكي

### ⚙️ البنية التحتية

- **تحميل سريع** — نفق HTTP (محرك v34 لا يدعم TLS)
- **مكافحة غش SMAC** — حماية متعددة الطبقات
- **Tickrate 100** — لعب سلس
- **Metamod + SourceMod** — إطار العمل للإضافات
- **نسخ احتياطي تلقائي** — نسخ بيانات الإضافات كل 12 ساعة
- **إعادة تشغيل ليلية** — إعادة تشغيل تلقائية الساعة 5 صباحًا مع تنبيه اللاعبين

---

## 📁 هيكل المشروع

```
├── plugins/
│   ├── scripting/          # كود المصدر (.sp)
│   └── compiled/           # الإضافات المترجمة (.smx)
├── configs/
│   ├── gamemodes/          # ملفات إعدادات أوضاع اللعب
│   └── sourcemod/          # إعدادات SourceMod
├── panel/
│   ├── panel.py            # لوحة التحكم (Python)
│   └── web/                # واجهة اللوحة
├── scripts/
│   ├── backup_plugin_data.sh   # سكربت النسخ الاحتياطي
│   ├── nightly_restart.sh      # سكربت إعادة التشغيل الليلية
│   └── fastdl_watch.py         # مراقب التحميل السريع
└── docs/
    └── INSTALL.md          # دليل التثبيت الكامل
```

---

## 🚀 البدء السريع

```bash
# استنساخ
git clone https://github.com/armadgarsone2/cssv34-server.git
cd cssv34-server

# تثبيت الإضافات
cp plugins/compiled/*.smx /path/to/cstrike/addons/sourcemod/plugins/

# تثبيت الإعدادات
cp configs/gamemodes/*.cfg /path/to/cstrike/cfg/gamemodes/
cp configs/sourcemod/* /path/to/cstrike/addons/sourcemod/configs/

# تثبيت اللوحة
cp panel/panel.py /path/to/cssserver/
cp -r panel/web /path/to/cssserver/

# إعادة تشغيل السيرفر
systemctl restart css34
```

📖 **الدليل الكامل:** [docs/INSTALL.md](docs/INSTALL.md)

---

## 🎮 أوامر اللاعبين

| الأمر | الوصف |
|-------|-------|
| `!shop` | فتح متجر الأزياء |
| `!rank` | عرض ترتيبك |
| `!top` | المتصدرون (عام) |
| `!top sniper` | المتصدرون (قنّاصون) |
| `!top rifle` | المتصدرون (بندقيون) |
| `!top knife` | المتصدرون (سكاكين) |
| `!knife` | اختيار السكين |
| `!rules` | قوانين السيرفر |
| `!credits` | التحقق من رصيد العملات |

---

## 🛠 أوامر المشرفين

| الأمر | الوصف |
|-------|-------|
| `sm_gag <player> [min] [reason]` | حظر الكلام |
| `sm_mute <player> [min]` | حظر الصوت |
| `sm_ungag / sm_unmute <player>` | إزالة الحظر |
| `sm_gaglist` | قائمة الحظر النشط |
| `sm_dm 0/1` | تفعيل/تعطيل إعادة ظهور الديث ماتش |
| `sm_adminlog` | عرض آخر إجراءات المشرفين |

---

## 📸 الأزياء المثبتة

**الأسلحة:** AK-47 Neon · AK-47 Hardened · AWP Creeper · Desert Eagle Gold · M4A1 NeoNoir
**السكاكين:** M9 Bayonet · Butterfly Knife
**القنابل:** HE · Smoke · Flashbang

---

## 🤝 المساهمة

مرحبًا بفتح Issues أو إرسال Pull Requests!

---

<div align="center">

### 🤖 تم البناء بالذكاء الاصطناعي

هذا المشروع بالكامل — تصميم البنية، تطوير إضافات SourcePawn،
هندسة لوحة التحكم، إعدادات أوضاع اللعب والتوثيق — تم إنشاؤه
من الصفر بمساعدة الذكاء الاصطناعي.

---

**⭐ لا تنسَ إعطاء نجمة للمشروع إذا ساعدك! ⭐**

[![GitHub stars](https://img.shields.io/github/stars/armadgarsone2/cssv34-server?style=for-the-badge&color=yellow)](https://github.com/armadgarsone2/cssv34-server/stargazers)

</div>
