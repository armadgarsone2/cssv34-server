#!/bin/bash
# fix_hang.sh — جلوگیری از هنگ شدن سرور CSS v34 هنگام استارت
#
# مشکل: بعد از «Network: IP ...» سرور سعی میکنه به سرورهای CM استیم
# (مثل 69.28.153.82:27038) وصل بشه. چون VPS راهی به استیم نداره، این connect()
# آویزون میمونه و سرور هنگ میکنه.
#
# راه‌حل: با iptables خروجی پورت‌های استیم رو reject میکنیم تا connect() فوری
# جواب بگیره و سرور بالا بیاد.
#
# ⚠️ قانون زیر رو حذف نکن، وگرنه هنگ بر میگرده.

set -euo pipefail

RULE="-p tcp --dport 27015:27050 ! -o lo -j REJECT --reject-with tcp-reset"

if iptables -C OUTPUT $RULE 2>/dev/null; then
    echo "[=] قانون iptables قبلاً هست، کاری نکردم."
else
    iptables -I OUTPUT $RULE
    echo "[✓] قانون iptables اضافه شد: OUTPUT $RULE"
fi

echo
echo "برای ماندگاری بعد از ریبوت: پکیج iptables-persistent رو نصب کن"
echo "  apt install iptables-persistent && netfilter-persistent save"
