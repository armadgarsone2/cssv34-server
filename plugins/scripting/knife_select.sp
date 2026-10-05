#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>

public Plugin myinfo = {
    name = "Knife Selector",
    author = "Sefidan",
    description = "Per-player knife choice: default / M9 / Butterfly",
    version = "1.0",
};

new g_knife[MAXPLAYERS + 1]; // 0=default 1=m9 2=butterfly
new String:g_auth[MAXPLAYERS + 1][64];

public OnPluginStart() {
    RegConsoleCmd("sm_knife", Cmd_Knife, "Choose your knife");
    CreateTimer(0.2, T_Tick, _, TIMER_REPEAT);
}

public OnMapStart() {
    PrecacheModel("models/weapons/v_knife_m9.mdl", true);
    PrecacheModel("models/weapons/w_knife_m9.mdl", true);
    PrecacheModel("models/weapons/v_knife_butterfly.mdl", true);
    PrecacheModel("models/weapons/w_knife_butterfly.mdl", true);
    PrecacheModel("models/weapons/anims/v_knife_m9_anims.mdl", true);
    PrecacheModel("models/weapons/anims/v_knife_butterfly_anim.mdl", true);
}

public OnClientPutInServer(client) {
    if (!GetClientAuthId(client, AuthId_Steam2, g_auth[client], 64))
        Format(g_auth[client], 64, "uid:%d", GetClientUserId(client));
    g_knife[client] = LoadChoice(g_auth[client]);
    if (g_knife[client] == 1)
        PrintToChat(client, "\x04[Knife]\x01 Your knife: \x03M9 Karel's\x01 (!knife to change)");
    else if (g_knife[client] == 2)
        PrintToChat(client, "\x04[Knife]\x01 Your knife: \x03Butterfly Blue Gem\x01 (!knife to change)");
}

LoadChoice(const String:auth[]) {
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/knife_choice.txt");
    new Handle:kv = CreateKeyValues("knives");
    new c = 0;
    if (FileToKeyValues(kv, path)) {
        KvRewind(kv);
        if (KvJumpToKey(kv, auth))
            c = KvGetNum(kv, "choice", 0);
    }
    CloseHandle(kv);
    return c;
}

SaveChoice(client) {
    if (g_auth[client][0] == 0) return;
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/knife_choice.txt");
    new Handle:kv = CreateKeyValues("knives");
    FileToKeyValues(kv, path);
    KvRewind(kv);
    KvJumpToKey(kv, g_auth[client], true);
    KvSetNum(kv, "choice", g_knife[client]);
    KeyValuesToFile(kv, path);
    CloseHandle(kv);
}

public Action:Cmd_Knife(client, args) {
    if (client == 0) return Plugin_Handled;
    new Handle:menu = CreateMenu(Menu_Knife);
    SetMenuTitle(menu, "Choose your knife");
    decl String:d0[32], String:d1[32], String:d2[32];
    strcopy(d0, 32, "Default Knife");
    strcopy(d1, 32, "M9 Karel's");
    strcopy(d2, 32, "Butterfly Blue Gem");
    if (g_knife[client] == 0) strcopy(d0, 32, "> Default Knife");
    if (g_knife[client] == 1) strcopy(d1, 32, "> M9 Karel's");
    if (g_knife[client] == 2) strcopy(d2, 32, "> Butterfly Blue Gem");
    AddMenuItem(menu, "0", d0);
    AddMenuItem(menu, "1", d1);
    AddMenuItem(menu, "2", d2);
    DisplayMenu(menu, client, 20);
    return Plugin_Handled;
}

public Menu_Knife(Handle:menu, MenuAction:action, client, param) {
    if (action == MenuAction_Select) {
        new String:info[8];
        GetMenuItem(menu, param, info, 8);
        g_knife[client] = StringToInt(info);
        SaveChoice(client);
        ApplyKnife(client);
        if (g_knife[client] == 0)
            PrintToChat(client, "\x04[Knife]\x01 Default knife selected.");
        else if (g_knife[client] == 1)
            PrintToChat(client, "\x04[Knife]\x01 Equipped\x03 M9 Karel's\x01!");
        else
            PrintToChat(client, "\x04[Knife]\x01 Equipped\x03 Butterfly Blue Gem\x01!");
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

public Action:T_Tick(Handle:timer) {
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && IsPlayerAlive(i) && g_knife[i] > 0)
            ApplyKnife(i);
    }
    return Plugin_Continue;
}

ApplyKnife(client) {
    if (g_knife[client] == 0) return;
    if (!IsClientInGame(client) || !IsPlayerAlive(client)) return;

    decl String:suffix[16];
    if (g_knife[client] == 1) strcopy(suffix, 16, "m9");
    else strcopy(suffix, 16, "butterfly");

    // world model on weapon entity (what others see)
    new count = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
    for (new i = 0; i < count; i++) {
        new ent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
        if (ent == -1 || !IsValidEntity(ent)) continue;
        decl String:cls[32];
        GetEntityClassname(ent, cls, sizeof(cls));
        if (StrEqual(cls, "weapon_knife")) {
            decl String:want[128], String:cur[128];
            Format(want, 128, "models/weapons/w_knife_%s.mdl", suffix);
            GetEntPropString(ent, Prop_Send, "m_ModelName", cur, sizeof(cur));
            if (!StrEqual(cur, want)) SetEntityModel(ent, want);
        }
    }

    // viewmodel (first person)
    new vm = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (vm != -1 && IsValidEntity(vm)) {
        decl String:want[128], String:cur[128];
        Format(want, 128, "models/weapons/v_knife_%s.mdl", suffix);
        GetEntPropString(vm, Prop_Send, "m_ModelName", cur, sizeof(cur));
        if (!StrEqual(cur, want)) SetEntityModel(vm, want);
    }
}
