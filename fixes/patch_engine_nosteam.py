#!/usr/bin/env python3
"""
patch_engine_nosteam.py — خنثی‌سازی خطای «STEAM validation rejected» در engine_i486.so

چرا: موتور CSourceServer::CheckChallengeType در engine_i486.so یه شرط داره که اگه
اعتبارسنجی بلیط استیم شکست بخوره (که برای کلاینت no-steam همیشه شکست میخوره)،
پیام «STEAM validation rejected» رو به کلاینت میفرسته و وصل نمیشه.

راه‌حل: اون شرط `jne` (پرش مشروط به مسیر موفق) رو به `jmp` (پرش همیشگی) تبدیل
میکنیم تا موتور همیشه مسیر «اجازه ورود» رو بره و هیچوقت به مسیر رد کردن نرسه.

آدرس‌ها مخصوص همین نسخه v34 (2009-08-26) هستن. فایل اصلی رو بکاپ میگیره.

استفاده:
    python3 patch_engine_nosteam.py /path/to/bin/engine_i486.so
    (یا بدون آرگومان: خودش engine_i486.so کنار این اسکریپت رو پچ میکنه)
"""
import sys, os, shutil, hashlib

# ---- آدرس‌های مخصوص engine_i486.so نسخه v34 (2009-08-26) ----
PATCH_OFFSET = 0x1751af            # محل دستور jne به مسیر موفق
OLD_BYTES = bytes.fromhex("0f8585feffff")   # jne 0x17503a  (پرش مشروط)
NEW_BYTES = bytes.fromhex("e986feffff90")   # jmp 0x17503a  (پرش همیشگی) + nop


def patch(path: str) -> None:
    bak = path + ".orig"
    if not os.path.exists(bak):
        shutil.copy2(path, bak)
        print(f"[+] بکاپ: {bak}")

    with open(path, "r+b") as f:
        f.seek(PATCH_OFFSET)
        old = f.read(len(OLD_BYTES))
        if old == NEW_BYTES:
            print("[=] قبلاً پچ شده، کاری نکردم.")
            return
        if old != OLD_BYTES:
            print(f"[!] بایت‌های سر جای نیستن: {old.hex()} (انتظار: {OLD_BYTES.hex()})")
            print("    احتمالاً نسخهٔ engine متفاوته. اسکریپت رو اجرا نکن.")
            sys.exit(1)
        f.seek(PATCH_OFFSET)
        f.write(NEW_BYTES)
        f.seek(PATCH_OFFSET)
        new = f.read(len(NEW_BYTES))

    print(f"[✓] پچ شد: {old.hex()} -> {new.hex()}")
    print(f"    md5: {hashlib.md5(open(path,'rb').read()).hexdigest()}")
    print("    حالا سرور رو ری‌استارت کن تا اعمال بشه.")


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "engine_i486.so")
    if not os.path.exists(target):
        print(f"[!] فایل پیدا نشد: {target}")
        sys.exit(1)
    patch(target)
