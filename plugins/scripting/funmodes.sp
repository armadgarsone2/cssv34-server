#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
    name = "Fun Modes",
    author = "Ali",
    description = "Sniper mode + Knife/Smoke mode",
    version = "1.0",
};

Handle g_cvSniper = null;
Handle g_cvKnife = null;

public void OnPluginStart() {
    g_cvSniper = CreateConVar("sm_sniper_mode", "0", "Sniper only mode", _, true, 0.0, true, 1.0);
    g_cvKnife  = CreateConVar("sm_knife_smoke", "0", "Knife + smoke mode", _, true, 0.0, true, 1.0);
    HookEvent("player_spawn", Ev_Spawn, EventHookMode_Post);
}

public void Ev_Spawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client)) return;
    int team = GetClientTeam(client);
    if (team != 2 && team != 3) return;
    CreateTimer(0.3, T_Give, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action T_Give(Handle timer, any uid) {
    int client = GetClientOfUserId(uid);
    if (client <= 0 || !IsClientInGame(client) || !IsPlayerAlive(client)) return Plugin_Stop;
    bool sniper = GetConVarBool(g_cvSniper);
    bool knife = GetConVarBool(g_cvKnife);
    if (!sniper && !knife) return Plugin_Stop;

    // strip weapons — keep slot 2 (knife)
    int slot;
    for (slot = 0; slot <= 5; slot++) {
        if (slot == 2) continue;
        int ent = GetPlayerWeaponSlot(client, slot);
        if (ent != -1) {
            RemovePlayerItem(client, ent);
            AcceptEntityInput(ent, "Kill");
        }
    }
    if (sniper) {
        GivePlayerItem(client, "weapon_awp");
        PrintToChat(client, " \x04🎯 حالت اسنایپر\x01 — فقط \x03AWP\x01 و چاقو!");
    } else {
        GivePlayerItem(client, "weapon_smokegrenade");
        GivePlayerItem(client, "weapon_smokegrenade");
        PrintToChat(client, " \x04🔪 حالت اسکی‌کامپ\x01 — فقط \x03چاقو و دودی\x01!");
    }
    return Plugin_Stop;
}
