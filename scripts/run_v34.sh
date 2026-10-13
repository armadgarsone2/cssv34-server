#!/bin/bash
# run_v34.sh — بالا آوردن سرور CSS v34 بدون استیم روی لینوکس
#
# این اسکریپت همون run_direct.sh سرور زنده‌ست که عیناً اینجا کپی شده.
# همه پچ‌ها (شیم no-steam + memfix) با LD_PRELOAD لود میشن.
#
# استفاده:
#   bash run_v34.sh
#
# مسیرها رو اگه جای دیگه‌ای نصب کردی عوض کن.

# مسیر ریشهٔ سرور (جایی که srcds_i486 هست)
DIR="${V34_DIR:-/root/cssv34/csds-v34-2009-08-26}"

# مسیر شیم و memfix (اگه کنار اسکریپت کامپایلشون کردی، درستش کن)
FIXDIR="${V34_FIXDIR:-/root/cssv34}"

cd "$DIR" || exit 1

# شیم no-steam باید اول باشه تا symهای استیم رو باطل کنه؛ memfix دوم
export LD_PRELOAD="$FIXDIR/nosteam_shim.so $FIXDIR/memfix.so"
export LD_LIBRARY_PATH="$DIR:$DIR/bin:$DIR/platform/bin:${LD_LIBRARY_PATH:-}"

exec ./srcds_i486 -game cstrike -console -usercon -nobreakpad -insecure \
    +ip 0.0.0.0 +port 27015 +maxplayers 16 +map de_dust2
