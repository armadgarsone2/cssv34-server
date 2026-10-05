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
    HookEvent("player_say", Ev_Say);
}

public void Ev_Say(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client)) return;
    char text[192];
    event.GetString("text", text, sizeof(text));
    int len = strlen(text);
    if (len < 1) return;
    if (text[0] == '!' || text[0] == '/') return;

    char pname[64];
    GetClientName(client, pname, sizeof(pname));
    char stamp[32];
    FormatTime(stamp, sizeof(stamp), "%H:%M");
    File f = OpenFile(CHAT_FILE, "a");
    if (f != null) {
        WriteFileLine(f, "[%s] %s : %s", stamp, pname, text);
        delete f;
    }
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
