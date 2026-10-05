#pragma semicolon 1
#include <sourcemod>
#include <cstrike>

#define AFK_TIME 300.0

float g_lastMove[MAXPLAYERS+1];
float g_lastPos[MAXPLAYERS+1][3];
bool g_warned[MAXPLAYERS+1];
int g_team[MAXPLAYERS+1];

public Plugin myinfo = {
    name = "AFK Manager",
    author = "Sefidan",
    description = "Move AFK players to spectator",
    version = "1.0",
};

public void OnPluginStart() {
    CreateTimer(20.0, T_Check, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client) {
    g_lastMove[client] = GetGameTime();
    g_warned[client] = false;
    g_team[client] = 0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Continue;
    if (buttons != 0 || GetVectorLength(vel) > 10.0) {
        g_lastMove[client] = GetGameTime();
        g_warned[client] = false;
    }
    return Plugin_Continue;
}

public Action T_Check(Handle timer) {
    float now = GetGameTime();
    for (int c = 1; c <= MaxClients; c++) {
        if (!IsClientInGame(c) || IsFakeClient(c)) continue;
        int team = GetClientTeam(c);
        if (team != 2 && team != 3) continue;
        float pos[3];
        GetClientAbsOrigin(c, pos);
        if (GetVectorDistance(pos, g_lastPos[c]) > 5.0) {
            g_lastPos[c] = pos;
            g_lastMove[c] = now;
            g_warned[c] = false;
        }
        float idle = now - g_lastMove[c];
        if (idle >= AFK_TIME - 60.0 && !g_warned[c] && idle < AFK_TIME) {
            g_warned[c] = true;
            PrintToChat(c, " \x04⚠️ شما %d ثانیه بی‌حرکت هستید\x01 — اگر تکان نخورید به تماشاگر می‌روید!", RoundFloat(AFK_TIME - idle));
        }
        if (idle >= AFK_TIME) {
            g_team[c] = team;
            ChangeClientTeam(c, 1);
            char aname[64];
            GetClientName(c, aname, sizeof(aname));
            PrintToChatAll(" \x04[AFK]\x01 \x03%s\x01 به دلیل بی‌حرکتی به \x03تماشاگر\x01 رفت", aname);
            g_lastMove[c] = now;
            g_warned[c] = false;
        }
    }
    return Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
    if (client > 0) {
        g_lastMove[client] = GetGameTime();
        g_warned[client] = false;
        int team = GetClientTeam(client);
        if (team == 1 && g_team[client] >= 2) {
            ChangeClientTeam(client, g_team[client]);
            PrintToChat(client, " \x04به تیم قبلی‌تان برگشتید\x01");
            g_team[client] = 0;
        }
    }
    return Plugin_Continue;
}


