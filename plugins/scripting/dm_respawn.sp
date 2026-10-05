#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
    name = "DM Respawn",
    author = "Sefidan",
    description = "Deathmatch auto-respawn with armor",
    version = "1.0",
};

new Handle:cvarDM = INVALID_HANDLE;

public OnPluginStart() {
    cvarDM = CreateConVar("sm_dm", "0", "Deathmatch mode on/off", _, true, 0.0, true, 1.0);
    HookEvent("player_death", Ev_Death);
    HookEvent("player_spawn", Ev_Spawn);
}

public Ev_Death(Handle:event, const String:name[], bool:dontBroadcast) {
    if (!GetConVarBool(cvarDM)) return;
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0) return;
    CreateTimer(3.0, T_Respawn, GetClientUserId(client));
}

public Action:T_Respawn(Handle:timer, any:uid) {
    new client = GetClientOfUserId(uid);
    if (client > 0 && IsClientInGame(client) && !IsPlayerAlive(client)
        && GetConVarBool(cvarDM) && GetClientTeam(client) >= 2) {
        CS_RespawnPlayer(client);
    }
    return Plugin_Stop;
}

public Ev_Spawn(Handle:event, const String:name[], bool:dontBroadcast) {
    if (!GetConVarBool(cvarDM)) return;
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || !IsClientInGame(client)) return;
    CreateTimer(0.3, T_Gear, GetClientUserId(client));
}

public Action:T_Gear(Handle:timer, any:uid) {
    new client = GetClientOfUserId(uid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetConVarBool(cvarDM)) {
        GivePlayerItem(client, "weapon_assaultsuit");
    }
    return Plugin_Stop;
}
