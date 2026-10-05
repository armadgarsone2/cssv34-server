#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>

#define PROT_TIME 3.0

float g_protEnd[MAXPLAYERS+1];
Handle g_hud = null;

public Plugin myinfo = {
    name = "Spawn Protect",
    author = "Sefidan",
    description = "3 second spawn protection",
    version = "1.0",
};

public void OnPluginStart() {
    g_hud = CreateHudSynchronizer();
    HookEvent("player_spawn", Ev_Spawn);
    for (int i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i)) SDKHook(i, SDKHook_OnTakeDamage, OnDamage);
}

public void OnClientPutInServer(int client) {
    g_protEnd[client] = 0.0;
    SDKHook(client, SDKHook_OnTakeDamage, OnDamage);
}

public void Ev_Spawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client)) return;
    int team = GetClientTeam(client);
    if (team != 2 && team != 3) return;
    g_protEnd[client] = GetGameTime() + PROT_TIME;
    CreateTimer(0.2, T_Hud, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Hud(Handle timer, any uid) {
    int client = GetClientOfUserId(uid);
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Stop;
    float left = g_protEnd[client] - GetGameTime();
    if (left <= 0.0) {
        g_protEnd[client] = 0.0;
        return Plugin_Stop;
    }
    SetHudTextParams(-1.0, 0.35, 0.25, 100, 255, 100, 255, 0, 0.0, 0.0, 0.0);
    ShowSyncHudText(client, g_hud, "🛡 محافظت: %0.1f", left);
    return Plugin_Continue;
}

public Action OnDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
    if (victim <= 0 || !IsClientInGame(victim)) return Plugin_Continue;
    if (g_protEnd[victim] > GetGameTime() && damage > 0.0) {
        damage = 0.0;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}
