#pragma semicolon 1
#include <sourcemod>

#define CHAT_FILE "/root/cssserver/cstrike/addons/sourcemod/data/chat_log.txt"

public Plugin myinfo = {
    name = "Chat Log + Admin Announce",
    author = "Ali",
    description = "Logs chat for panel, announces admin joins",
    version = "1.0",
};

public void OnPluginStart() {
    // OnClientSayCommand is reliable on CS:S v34; player_say event is not
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
    if (client <= 0 || IsFakeClient(client)) return Plugin_Continue;
    int len = strlen(sArgs);
    if (len < 1) return Plugin_Continue;
    if (sArgs[0] == '!' || sArgs[0] == '/') return Plugin_Continue;

    char pname[64];
    GetClientName(client, pname, sizeof(pname));
    char stamp[32];
    FormatTime(stamp, sizeof(stamp), "%H:%M");
    File f = OpenFile(CHAT_FILE, "a");
    if (f != null) {
        WriteFileLine(f, "[%s] %s : %s", stamp, pname, sArgs);
        delete f;
    }
    return Plugin_Continue;
}

public void OnClientPutInServer(int client) {
    CreateTimer(6.0, T_Announce, GetClientUserId(client));
}

public Action T_Announce(Handle timer, any uid) {
    int client = GetClientOfUserId(uid);
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client)) return Plugin_Stop;
    int adminId = GetUserAdmin(client);
    if (adminId != INVALID_ADMIN_ID) {
        char pname[64];
        GetClientName(client, pname, sizeof(pname));
        PrintToChatAll(" \x04👑 ادمین\x01 \x03%s\x01 به سرور پیوست!", pname);
    }
    return Plugin_Stop;
}
