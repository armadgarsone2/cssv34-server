#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define DATA_FILE "data/ranks.txt"
#define MAX_ENTRIES 512

char a_auth[MAX_ENTRIES][64];
char a_name[MAX_ENTRIES][64];
int a_k[MAX_ENTRIES];
int a_d[MAX_ENTRIES];
int a_hs[MAX_ENTRIES];
int a_c[MAX_ENTRIES][8];
int a_count = 0;

int g_idx[MAXPLAYERS+1];

public Plugin myinfo = {
    name = "Rank System",
    author = "Sefidan",
    description = "Overall + per-weapon-class ranking",
    version = "1.0",
};

public void OnPluginStart() {
    LoadRanks();
    HookEvent("player_death", Ev_Death);
    RegConsoleCmd("sm_rank", Cmd_Rank, "My rank");
    RegConsoleCmd("sm_top", Cmd_Top, "Top players");
    CreateTimer(60.0, T_Save, _, TIMER_REPEAT);
}

public void OnMapEnd() { SaveRanks(); }
public void OnPluginEnd() { SaveRanks(); }

public Action T_Save(Handle timer) { SaveRanks(); return Plugin_Continue; }

int ClassOf(const char[] w) {
    if (StrEqual(w, "awp") || StrEqual(w, "scout")) return 1;
    if (StrEqual(w, "ak47") || StrEqual(w, "m4a1") || StrEqual(w, "sg552") ||
        StrEqual(w, "aug") || StrEqual(w, "famas") || StrEqual(w, "galil")) return 2;
    if (StrEqual(w, "mp5navy") || StrEqual(w, "tmp") || StrEqual(w, "ump45") ||
        StrEqual(w, "p90") || StrEqual(w, "mac10")) return 3;
    if (StrEqual(w, "m3") || StrEqual(w, "xm1014")) return 4;
    if (StrEqual(w, "usp") || StrEqual(w, "glock") || StrEqual(w, "p228") ||
        StrEqual(w, "elite") || StrEqual(w, "fiveseven") || StrEqual(w, "deagle")) return 5;
    if (StrEqual(w, "knife")) return 6;
    return 7;
}

int FindOrCreate(int client) {
    char auth[64];
    GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
    for (int i = 0; i < a_count; i++) {
        if (StrEqual(a_auth[i], auth)) {
            GetClientName(client, a_name[i], 64);
            return i;
        }
    }
    if (a_count >= MAX_ENTRIES) return -1;
    strcopy(a_auth[a_count], 64, auth);
    GetClientName(client, a_name[a_count], 64);
    a_k[a_count] = 0; a_d[a_count] = 0; a_hs[a_count] = 0;
    for (int c = 0; c < 8; c++) a_c[a_count][c] = 0;
    a_count++;
    return a_count - 1;
}

public void OnClientPutInServer(int client) {
    if (IsFakeClient(client)) { g_idx[client] = -1; return; }
    g_idx[client] = FindOrCreate(client);
}

public void Ev_Death(Event event, const char[] name, bool dontBroadcast) {
    int victim = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (victim <= 0 || !IsClientInGame(victim) || IsFakeClient(victim)) return;
    int vi = FindOrCreate(victim);
    if (vi >= 0) a_d[vi]++;
    if (attacker <= 0 || attacker == victim || !IsClientInGame(attacker) || IsFakeClient(attacker)) return;
    // teamkill — not a real kill
    if (GetClientTeam(attacker) == GetClientTeam(victim)) return;
    char w[32];
    event.GetString("weapon", w, sizeof(w));
    int ai = FindOrCreate(attacker);
    if (ai < 0) return;
    a_k[ai]++;
    int cls = ClassOf(w);
    a_c[ai][cls]++;
    if (event.GetInt("hitgroup") == 1) a_hs[ai]++;
}

public Action Cmd_Rank(int client, int args) {
    if (client == 0) return Plugin_Handled;
    int idx = FindOrCreate(client);
    if (idx < 0) { PrintToChat(client, " \x04خطا در پیدا کردن رکورد\x01"); return Plugin_Handled; }
    int rank = 1;
    for (int i = 0; i < a_count; i++)
        if (i != idx && (a_k[i] > a_k[idx] || (a_k[i] == a_k[idx] && a_hs[i] > a_hs[idx]))) rank++;
    float kd = (a_d[idx] > 0) ? (float(a_k[idx]) / float(a_d[idx])) : float(a_k[idx]);
    int hs = (a_k[idx] > 0) ? RoundFloat(float(a_hs[idx]) * 100.0 / float(a_k[idx])) : 0;
    PrintToChat(client, " \x04*+* رتبه شما *+*");
    PrintToChat(client, " \x01رتبه کلی: \x03#%d\x01 از \x03%d\x01 نفر", rank, a_count);
    PrintToChat(client, " \x01کیل: \x03%d\x01 | مرگ: \x03%d\x01 | KD: \x03%.2f\x01 | هددشات: \x03%d%%", a_k[idx], a_d[idx], kd, hs);
    PrintToChat(client, " \x01🔫 اسنایپر: \x03%d\x01 | رایفل: \x03%d\x01 | اسمگ: \x03%d\x01 | شاتگان: \x03%d", a_c[idx][1], a_c[idx][2], a_c[idx][3], a_c[idx][4]);
    PrintToChat(client, " \x01کلت: \x03%d\x01 | چاقو: \x03%d\x01 | نارنجک: \x03%d", a_c[idx][5], a_c[idx][6], a_c[idx][7]);
    return Plugin_Handled;
}

public Action Cmd_Top(int client, int args) {
    if (client == 0) return Plugin_Handled;
    char clsArg[16] = "";
    if (args >= 1) GetCmdArg(1, clsArg, sizeof(clsArg));
    int cls = 0;
    if (StrEqual(clsArg, "sniper", false) || StrEqual(clsArg, "awp", false)) cls = 1;
    else if (StrEqual(clsArg, "rifle", false)) cls = 2;
    else if (StrEqual(clsArg, "smg", false)) cls = 3;
    else if (StrEqual(clsArg, "shotgun", false)) cls = 4;
    else if (StrEqual(clsArg, "pistol", false)) cls = 5;
    else if (StrEqual(clsArg, "knife", false)) cls = 6;
    else if (StrEqual(clsArg, "nade", false)) cls = 7;

    int order[MAX_ENTRIES];
    int n = 0;
    for (int i = 0; i < a_count; i++) {
        int val = (cls == 0) ? a_k[i] : a_c[i][cls];
        if (val <= 0) continue;
        order[n++] = i;
    }
    // selection sort desc
    for (int s = 0; s < n && s < 10; s++) {
        int best = s;
        for (int j = s + 1; j < n; j++) {
            int vj = (cls == 0) ? a_k[order[j]] : a_c[order[j]][cls];
            int vb = (cls == 0) ? a_k[order[best]] : a_c[order[best]][cls];
            if (vj > vb || (vj == vb && a_hs[order[j]] > a_hs[order[best]])) best = j;
        }
        int tmp = order[s]; order[s] = order[best]; order[best] = tmp;
    }
    char title[32];
    if (cls == 0) strcopy(title, sizeof(title), "کلی");
    else if (cls == 1) strcopy(title, sizeof(title), "اسنایپر");
    else if (cls == 2) strcopy(title, sizeof(title), "رایفل");
    else if (cls == 3) strcopy(title, sizeof(title), "اس‌ام‌جی");
    else if (cls == 4) strcopy(title, sizeof(title), "شاتگان");
    else if (cls == 5) strcopy(title, sizeof(title), "کلت");
    else if (cls == 6) strcopy(title, sizeof(title), "چاقو");
    else strcopy(title, sizeof(title), "نارنجک");

    PrintToChat(client, " \x04*+* برترین‌ها — %s *+*", title);
    int show = (n < 10) ? n : 10;
    if (show == 0) { PrintToChat(client, " \x01هنوز آماری ثبت نشده"); return Plugin_Handled; }
    char medals[4][8];
    strcopy(medals[0], 8, "\x04🥇");
    strcopy(medals[1], 8, "\x03🥈");
    strcopy(medals[2], 8, "\x02🥉");
    strcopy(medals[3], 8, "\x01");
    for (int s = 0; s < show; s++) {
        int i = order[s];
        int val = (cls == 0) ? a_k[i] : a_c[i][cls];
        char m[8];
        if (s < 3) strcopy(m, 8, medals[s]);
        else strcopy(m, 8, "");
        PrintToChat(client, " %s\x03%d.\x01 %s — \x03%d", m, s + 1, a_name[i], val);
    }
    return Plugin_Handled;
}

void LoadRanks() {
    char path[256];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    a_count = 0;
    if (!FileExists(path)) return;
    File f = OpenFile(path, "r");
    if (f == null) return;
    char line[256];
    while (ReadFileLine(f, line, sizeof(line))) {
        char p[12][64];
        int n = ExplodeString(line, ";", p, 12, 64);
        if (n < 4) continue;
        if (a_count >= MAX_ENTRIES) break;
        strcopy(a_auth[a_count], 64, p[0]);
        strcopy(a_name[a_count], 64, p[1]);
        a_k[a_count] = StringToInt(p[2]);
        a_d[a_count] = StringToInt(p[3]);
        a_hs[a_count] = (n > 4) ? StringToInt(p[4]) : 0;
        for (int c = 0; c < 7; c++)
            a_c[a_count][c + 1] = (n > 5 + c) ? StringToInt(p[5 + c]) : 0;
        a_count++;
    }
    delete f;
}

void SaveRanks() {
    char path[256];
    BuildPath(Path_SM, path, sizeof(path), DATA_FILE);
    File f = OpenFile(path, "w");
    if (f == null) return;
    for (int i = 0; i < a_count; i++) {
        WriteFileLine(f, "%s;%s;%d;%d;%d;%d;%d;%d;%d;%d;%d;%d",
            a_auth[i], a_name[i], a_k[i], a_d[i], a_hs[i],
            a_c[i][1], a_c[i][2], a_c[i][3], a_c[i][4], a_c[i][5], a_c[i][6], a_c[i][7]);
    }
    delete f;
}
