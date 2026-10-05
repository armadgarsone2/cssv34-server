/**
 * Admin Action Log
 * Logs every admin action (kick, ban, gag, mute, map change, etc.)
 * to data/admin_log.txt for panel review
 * SM 1.7 old syntax — OnLogAction prototype must match logging.inc exactly
 */
#pragma semicolon 1
#include <sourcemod>

#define LOG_FILE "/root/cssserver/cstrike/addons/sourcemod/data/admin_log.txt"

public Plugin:myinfo = {
    name = "Admin Action Log",
    author = "Sefidan",
    description = "Logs all admin actions to file",
    version = "1.0",
};

public OnPluginStart() {
    RegAdminCmd("sm_adminlog", Cmd_ShowLog, ADMFLAG_GENERIC, "Show recent admin log entries");
}

// SM 1.7 prototype: OnLogAction(Handle:source, Identity:ident, client, target, const String:message[])
public Action:OnLogAction(Handle:source, Identity:ident, client, target, const String:message[]) {
    new String:adminName[64];
    if (client > 0 && IsClientInGame(client))
        GetClientName(client, adminName, sizeof(adminName));
    else
        strcopy(adminName, sizeof(adminName), "SERVER");

    new String:targetName[64] = "";
    if (target > 0 && IsClientInGame(target))
        GetClientName(target, targetName, sizeof(targetName));

    new String:stamp[32];
    FormatTime(stamp, sizeof(stamp), "%Y-%m-%d %H:%M");

    new Handle:f = OpenFile(LOG_FILE, "a");
    if (f != INVALID_HANDLE) {
        if (targetName[0])
            WriteFileLine(f, "[%s] %s -> %s : %s", stamp, adminName, targetName, message);
        else
            WriteFileLine(f, "[%s] %s : %s", stamp, adminName, message);
        CloseHandle(f);
    }
    return Plugin_Continue;
}

public Action:Cmd_ShowLog(client, args) {
    if (!FileExists(LOG_FILE)) {
        ReplyToCommand(client, "\x04لاگی ثبت نشده");
        return Plugin_Handled;
    }
    new Handle:f = OpenFile(LOG_FILE, "r");
    if (f == INVALID_HANDLE) return Plugin_Handled;

    new String:lines[10][192];
    new total = 0;
    new String:line[192];
    while (ReadFileLine(f, line, sizeof(line))) {
        strcopy(lines[total % 10], 192, line);
        total++;
    }
    CloseHandle(f);

    ReplyToCommand(client, "\x04* آخرین اکشن‌های ادمین *");
    new start = (total > 10) ? (total - 10) : 0;
    for (new i = start; i < total; i++) {
        ReplyToCommand(client, " \x03%s", lines[i % 10]);
    }
    return Plugin_Handled;
}
