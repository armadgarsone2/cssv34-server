#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define DATA_FILE "data/gags.txt"
#define MAX_ENTRIES 64

int g_expire[MAXPLAYERS+1];
int g_type[MAXPLAYERS+1];
char g_reason[MAXPLAYERS+1][64];

char e_auth[MAX_ENTRIES][64];
int e_expire[MAX_ENTRIES];
int e_type[MAX_ENTRIES];
char e_reason[MAX_ENTRIES][64];
int e_count = 0;

public Plugin myinfo = {
    name = "Gag Mute",
    author = "Sefidan",
    description = "Admin gag/mute with persistence",
    version = "1.0",
};

public void OnPluginStart() {
    RegAdminCmd("sm_gag",   Cmd_Gag,   ADMFLAG_CHAT, "gag text chat");
    RegAdminCmd("sm_ungag", Cmd_Ungag, ADMFLAG_CHAT, "remove gag");
    RegAdminCmd("sm_mute",  Cmd_Mute,  ADMFLAG_CHAT, "mute voice");
    RegAdminCmd("sm_unmute",Cmd_Unmute,ADMFLAG_CHAT, "remove mute");
    RegAdminCmd("sm_gaglist",Cmd_List, ADMFLAG_CHAT, "list gags");
    LoadGags();
    CreateTimer(15.0, T_Check, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client) {
    g_expire[client] = 0;
    g_type[client] = 0;
    g_reason[client][0] = 0;
    char auth[64];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    int now = GetTime();
    for (int i = 0; i < e_count; i++) {
        if (StrEqual(e_auth[i], auth)) {
            if (e_expire[i] == 0 || e_expire[i] > now) {
                g_expire[client] = e_expire[i];
                g_type[client] = e_type[i];
                strcopy(g_reason[client], 64, e_reason[i]);
                ApplyVoice(client);
                if (g_type[client] & 1)
                    PrintToChat(client, " \x04شما گگ هستید\x01. دلیل: \x03%s", g_reason[client]);
            }
            break;
        }
    }
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
    if (client > 0 && (g_type[client] & 1)) {
        int now = GetTime();
        if (g_expire[client] == 0 || g_expire[client] > now) {
            // commands still allowed for gagged players
            if (sArgs[0] == '!' || sArgs[0] == '/') return Plugin_Continue;
            return Plugin_Handled;
        }
    }
    return Plugin_Continue;
}

public Action T_Check(Handle timer) {
    int now = GetTime();
    for (int c = 1; c <= MaxClients; c++) {
        if (!IsClientInGame(c)) continue;
        if (g_expire[c] == 0) continue;
        if (g_expire[c] <= now) {
            g_expire[c] = 0;
            g_type[c] = 0;
            ApplyVoice(c);
            PrintToChat(c, " \x04گگ/مت شما برداشته شد\x01. می‌توانید صحبت کنید!");
            SaveGags();
        }
    }
    return Plugin_Continue;
}

void ApplyVoice(int client) {
    if (!IsClientInGame(client)) return;
    if (g_type[client] & 2)
        SetClientListeningFlags(client, VOICE_MUTED);
    else
        SetClientListeningFlags(client, VOICE_NORMAL);
}

public Action Cmd_Gag(int client, int args) {
    return DoGag(client, args, 1);
}
public Action Cmd_Mute(int client, int args) {
    return DoGag(client, args, 2);
}

Action DoGag(int client, int args, int type) {
    if (args < 1) {
        ReplyToCommand(client, "Usage: sm_gag/sm_mute <player> [minutes] [reason]");
        return Plugin_Handled;
    }
    char targ[64]; GetCmdArg(1, targ, sizeof(targ));
    int mins = 10;
    char reason[64] = "بدون دلیل";
    if (args >= 2) { char a[16]; GetCmdArg(2, a, sizeof(a)); mins = StringToInt(a); }
    if (args >= 3) { char a[64]; GetCmdArg(3, a, sizeof(a)); strcopy(reason, sizeof(reason), a); }

    int targets[MAXPLAYERS];
    char tn[64];
    bool tn_ml;
    int tn_num = ProcessTargetString(targ, client, targets, sizeof(targets), ADMFLAG_CHAT, tn, sizeof(tn), tn_ml);
    if (tn_num <= 0) {
        ReplyToCommand(client, "\x04بازیکن پیدا نشد\x01");
        return Plugin_Handled;
    }
    int now = GetTime();
    for (int i = 0; i < tn_num; i++) {
        int t = targets[i];
        if (t <= 0 || !IsClientInGame(t)) continue;
        g_type[t] |= type;
        g_expire[t] = (mins <= 0) ? 2147483647 : (now + mins * 60);
        strcopy(g_reason[t], 64, reason);
        ApplyVoice(t);
        char name[64]; GetClientName(t, name, sizeof(name));
        PrintToChatAll(" \x04[%s]\x01 \x03%s\x01 به مدت \x03%d\x01 دقیقه گرفته شد — دلیل: %s",
            type==1?"گگ":"مت", name, mins, reason);
        char auth[64]; GetClientAuthId(t, AuthId_Steam2, auth, sizeof(auth));
        bool found = false;
        for (int e = 0; e < e_count; e++) {
            if (StrEqual(e_auth[e], auth)) {
                e_expire[e] = g_expire[t];
                e_type[e] = g_type[t];
                strcopy(e_reason[e], 64, reason);
                found = true;
                break;
            }
        }
        if (!found && e_count < MAX_ENTRIES) {
            strcopy(e_auth[e_count], 64, auth);
            e_expire[e_count] = g_expire[t];
            e_type[e_count] = g_type[t];
            strcopy(e_reason[e_count], 64, reason);
            e_count++;
        }
    }
    SaveGags();
    return Plugin_Handled;
}

public Action Cmd_Ungag(int client, int args) { return DoUngag(client, args, 1); }
public Action Cmd_Unmute(int client, int args) { return DoUngag(client, args, 2); }

Action DoUngag(int client, int args, int type) {
    if (args < 1) {
        ReplyToCommand(client, "Usage: sm_ungag/sm_unmute <player>");
        return Plugin_Handled;
    }
    char targ[64]; GetCmdArg(1, targ, sizeof(targ));
    int targets[MAXPLAYERS];
    char tn[64];
    bool tn_ml;
    int tn_num = ProcessTargetString(targ, client, targets, sizeof(targets), ADMFLAG_CHAT, tn, sizeof(tn), tn_ml);
    if (tn_num <= 0) {
        ReplyToCommand(client, "\x04بازیکن پیدا نشد\x01");
        return Plugin_Handled;
    }
    for (int i = 0; i < tn_num; i++) {
        int t = targets[i];
        if (t <= 0 || !IsClientInGame(t)) continue;
        g_type[t] &= ~type;
        if (g_type[t] == 0) g_expire[t] = 0;
        ApplyVoice(t);
        char name[64]; GetClientName(t, name, sizeof(name));
        PrintToChatAll(" \x04[%s]\x01 \x03%s\x01 برداشته شد", type==1?"گگ":"مت", name);
        char auth[64]; GetClientAuthId(t, AuthId_Steam2, auth, sizeof(auth));
        for (int e = 0; e < e_count; e++) {
            if (StrEqual(e_auth[e], auth)) {
                e_type[e] = g_type[t];
                e_expire[e] = g_expire[t];
            }
        }
    }
    SaveGags();
    return Plugin_Handled;
}

public Action Cmd_List(int client, int args) {
    int now = GetTime();
    int n = 0;
    ReplyToCommand(client, "\x04* لیست گگ/مت *");
    for (int c = 1; c <= MaxClients; c++) {
        if (!IsClientInGame(c) || g_expire[c] == 0) continue;
        char name[64]; GetClientName(c, name, sizeof(name));
        int left = (g_expire[c] == 2147483647) ? 0 : (g_expire[c] - now) / 60;
        char what[16];
        if ((g_type[c]&1) && (g_type[c]&2)) strcopy(what, sizeof(what), "گگ+مت");
        else if (g_type[c]&1) strcopy(what, sizeof(what), "گگ");
        else strcopy(what, sizeof(what), "مت");
        ReplyToCommand(client, "\x03%s\x01 — %s — %d دقیقه — %s", name, what, left, g_reason[c]);
        n++;
    }
    if (n == 0) ReplyToCommand(client, "\x01کسی گگ/مت نیست");
    return Plugin_Handled;
}

void LoadGags() {
    char path[256];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    e_count = 0;
    if (!FileExists(path)) return;
    File f = OpenFile(path, "r");
    if (f == null) return;
    char line[256];
    while (ReadFileLine(f, line, sizeof(line))) {
        char parts[4][64];
        int n = ExplodeString(line, ";", parts, 4, 64);
        if (n < 3) continue;
        if (e_count >= MAX_ENTRIES) break;
        strcopy(e_auth[e_count], 64, parts[0]);
        e_expire[e_count] = StringToInt(parts[1]);
        e_type[e_count] = StringToInt(parts[2]);
        if (n >= 4) strcopy(e_reason[e_count], 64, parts[3]);
        e_count++;
    }
    delete f;
}

void SaveGags() {
    char path[256];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    File f = OpenFile(path, "w");
    if (f == null) return;
    int now = GetTime();
    for (int i = 0; i < e_count; i++) {
        if (e_expire[i] != 0 && e_expire[i] <= now) continue;
        if (e_type[i] == 0) continue;
        WriteFileLine(f, "%s;%d;%d;%s", e_auth[i], e_expire[i], e_type[i], e_reason[i]);
    }
    delete f;
}
