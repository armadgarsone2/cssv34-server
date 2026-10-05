#!/bin/bash
# Backup CSS v34 plugin data — ranks, gags, shop, knife choices, configs
STAMP=$(date +%Y%m%d_%H%M)
DEST=/root/backups/plugin_data
SM_DATA=/root/cssserver/cstrike/addons/sourcemod/data
CS_CFG=/root/cssserver/cstrike

tar czf "$DEST/plugin_data_${STAMP}.tar.gz" \
  -C "$SM_DATA" ranks.txt gags.txt shop_credits.txt shop_own.txt knife_choice.txt chat_log.txt 2>/dev/null
tar czf "$DEST/configs_${STAMP}.tar.gz" \
  -C "$CS_CFG" banned_userids.cfg mapcycle.txt \
  -C "$CS_CFG/addons/sourcemod/configs" admins_simple.ini shop_items.cfg 2>/dev/null

# keep last 14 backups (7 days x 2)
cd "$DEST"
ls -t plugin_data_*.tar.gz 2>/dev/null | tail -n +15 | xargs -r rm -f
ls -t configs_*.tar.gz 2>/dev/null | tail -n +15 | xargs -r rm -f
echo "$(date) backed up" >> "$DEST/backup.log"
