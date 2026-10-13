# راه‌اندازی سرور CSS v34 بدون استیم — از صفر تا صد

این ریپو همه چیزی که لازمه تا سرور کانتر-استرایک سورس v34 (2009) روی لینوکس
**بدون استیم** بالا بیاد رو داره. اگه سرور افتاد، فقط لینک این ریپو رو بده تا
از نو راهش بندازن.

---

## ⚡ خلاصهٔ سریع (۳ سوت)

```bash
# ۱) فایل بازی رو داشته باش (csds-v34-2009-08-26) — لینک مستقیم رو کاربر میده
# ۲) پچ‌ها رو بزن
bash fixes/fix_hang.sh                              # جلوگیری از هنگ (iptables)
python3 fixes/patch_engine_nosteam.py $DIR/bin/engine_i486.so
# ۳) شیم و memfix رو کامپایل و نصب کن
gcc -m32 -shared -fPIC -O2 -o /root/cssv34/nosteam_shim.so fixes/nosteam_shim.c
gcc -m32 -shared -fPIC -O2 -o /root/cssv34/memfix.so fixes/memfix.c
# ۴) کانفیگ‌ها رو کپی کن
cp configs/server/server.cfg  $DIR/cstrike/cfg/
cp configs/server/autoexec.cfg $DIR/cstrike/cfg/
# ۵) بالا بیار
bash scripts/run_v34.sh
```

---

## 📦 چی توی این ریپو هست

| مسیر | چیه |
|------|------|
| `fixes/nosteam_shim.c` | شیم no-steam — کتابخانهٔ اعتبارسنجی استیم رو باطل میکنه |
| `fixes/memfix.c` | رفع باگ بافر memcpy (جلوگیری از فرمان‌های خراب/هنگ) |
| `fixes/patch_engine_nosteam.py` | پچ engine برای خنثی‌سازی «STEAM validation rejected» |
| `fixes/fix_hang.sh` | قانون iptables برای جلوگیری از هنگ موقع استارت |
| `configs/server/server.cfg` | کانفیگ سرور (آماده کپی) |
| `configs/server/autoexec.cfg` | لود خودکار مپ de_dust2 |
| `scripts/run_v34.sh` | اسکریپت اجرا با همه پچ‌ها |
| `configs/gamemodes/*.cfg` | حالت‌های بازی (public, dm, comp, gungame, ...) |
| `plugins/` | پلاگین‌های SourceMod (compiled + scripting) |
| `panel/` | پنل مدیریت تحت وب |
| `scripts/*.sh, *.py` | اسکریپت‌های کمکی (بکاپ، ری‌استارت شبانه، فست‌دانلود) |

---

## 🔧 راهنمای قدم‌به‌قدم

### پیش‌نیاز

```bash
# نیاز به gcc 32 بیتی
apt update && apt install -y gcc-multilib iptables
```

### ۱. فایل بازی

فایل `csds-v34-2009-08-26.zip` (حدود ۵۸۶ مگ) رو استخراج کن به مثلاً
`/root/cssv34/csds-v34-2009-08-26/`. باید `srcds_i486` توش باشه.

> ⚠️ **خط قرمز:** دانلود فایل بازی Valve توسط دستیار از اینترنت ممنوعه.
> لینک مستقیمش رو **خودِ کاربر** میده.

**لینک دانلود سرور v34 (اختصاصی، نیازی به دانلود توسط دستیار نیست):**
https://files.hl2go.com/downloads/css-v34-dedicated-server-and-tools/

فایل مورد نیاز: `csds-v34-2009-08-26.zip` (حدود ۵۸۶ مگ).

### ۲. جلوگیری از هنگ (iptables)

```bash
bash fixes/fix_hang.sh
```

سرور موقع استارت میخواد به CM استیم وصل بشه؛ چون راه نداره، هنگ میکنه.
این قانون reject میزنه تا فوری جواب بگیره. **این قانون رو حذف نکن.**

### ۳. پچ موتور (رفع «STEAM validation rejected»)

```bash
python3 fixes/patch_engine_nosteam.py /root/cssv34/csds-v34-2009-08-26/bin/engine_i486.so
```

یه شرط داخل `engine_i486.so` (تابع `CBaseServer::CheckChallengeType`) که اگه
اعتبارسنجی بلیط استیم شکست بخوره، پیام رد میفرسته. این پچ اون رو از «پرش
مشروط» به «پرش همیشگی» تبدیل میکنه تا همیشه اجازهٔ ورود بده.

فایل اصلی به‌صورت `engine_i486.so.orig` بکاپ میگیره.

> **برگردوندن به حالت اصلی:** `mv engine_i486.so.orig engine_i486.so`

### ۴. کامپایل شیم و memfix

```bash
gcc -m32 -shared -fPIC -O2 -o /root/cssv34/nosteam_shim.so fixes/nosteam_shim.c
gcc -m32 -shared -fPIC -O2 -o /root/cssv34/memfix.so fixes/memfix.c
```

> شیم no-steam باید سیستم‌فایل رو پیدا کنی و اگه `engine_i486.so` لود نشد،
> شیم رو **همراهش** با `LD_PRELOAD` بیار (توی `run_v34.sh` هست).

**نکته:** کتابخانهٔ `libsteamvalidateuseridtickets_i486.so` رو با شیم جایگزین نکن
(مگه همه symهاش رو داشته باشه) — بهتره با `LD_PRELOAD` لود بشه.

### ۵. کانفیگ‌ها

```bash
cp configs/server/server.cfg   /root/cssv34/csds-v34-2009-08-26/cstrike/cfg/
cp configs/server/autoexec.cfg /root/cssv34/csds-v34-2009-08-26/cstrike/cfg/
```

نکات مهم no-steam داخل `server.cfg`:
```
sv_lan 0            # اگه 1 باشه کلاینت اینترنتی خطای class C میگیره
sv_pure 0
sv_consistency 0
sv_steamgroup ""
sv_hibernate_when_empty 0
```

### ۶. اجرا

```bash
bash scripts/run_v34.sh
```

یا با tmux (پیشنهادی برای اجرا در پس‌زمینه):
```bash
tmux new-session -d -s v34 'bash scripts/run_v34.sh > /tmp/v34.log 2>&1'
```

### ۷. تست

```bash
# A2S (اطلاعات سرور)
python3 a2s_info.py            # اسکریپت تست A2S

# از کلاینت بازی:
connect 3.128.226.176:27015
```

---

## ❗ عیب‌یابی سریع

### سرور بالا نمیاد / هنگ میکنه
```bash
# ۱) قانون iptables هست؟
iptables -L OUTPUT -n | grep 27015
# نبود؟ → bash fixes/fix_hang.sh

# ۲) engine پچ شده؟
python3 - <<'EOF'
p="/root/cssv34/csds-v34-2009-08-26/bin/engine_i486.so"
print(open(p,'rb').read()[0x1751af:0x1751b5].hex())
EOF
# باید بده: e986feffff90
```

### «STEAM validation rejected»
پچ موتور (قدم ۳) اعمال نشده یا نسخهٔ engine فرق داره. دوباره پچ بزن.

### «LAN servers are restricted to local client (class C)»
`sv_lan` روی 1 هست — باید 0 باشه.

### «Unknown command ex/» یا فرمان‌های خراب
memfix لود نشده. مطمئن شو `LD_PRELOAD` شامل `memfix.so` هست.

### پلاگین‌های SourceMod لود نمیشن (DLLInit=false)
Metamod/source رو نصب کن:
```bash
# متامود و سورس‌مود مخصوص لینوکس v34
```

---

## 🌐 پنل مدیریت

پنل وب توی `panel/` هست. با `panel/panel.py` راه میندازی. (جزئیات INSTALL.md)

---

**ساخته‌شده برای سرور Sefidan CSS | 100 Tick — ۲۰۲۶**
