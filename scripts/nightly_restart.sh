#!/bin/bash
# Nightly restart at 05:00 Tehran (01:30 UTC) with player warnings
RCON_PASS=$(cat /root/cssserver/rcon_pass.txt | cut -d= -f2 | tr -d ' ')

rcon() {
  python3 -c "
import socket, time
s = socket.socket(); s.settimeout(8)
s.connect(('127.0.0.1', 27016))
s.sendall(b'''$1''')
time.sleep(0.8)
try: s.recv(65536)
except: pass
s.close()"
}

# warn 5 min before
rcon 'say \" \\x04[SYSTEM]\\x01 سرور \\x035 دقیقه\\x01 دیگر ری‌استارت می‌شود! دست‌ها را آماده کنید\"'
sleep 240

# warn 1 min before
rcon 'say \" \\x04[SYSTEM]\\x01 سرور \\x031 دقیقه\\x01 دیگر ری‌استارت می‌شود! خروج بزنید\"'
sleep 55

# final warn
rcon 'say \" \\x04[SYSTEM]\\x01 ری‌استارت... تا چند لحظه دیگر وصل شوید!\"'
sleep 5

systemctl restart css34
echo "$(date) nightly restart done" >> /root/backups/plugin_data/restart.log
