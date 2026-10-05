#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define MAX_ITEMS 24
#define START_CREDITS 500

public Plugin myinfo = {
    name = "Simple Shop",
    author = "Ali",
    description = "In-game shop v3: player skins only (gun skins are server default)",
    version = "3.0",
};

new g_itemCount = 0;
new String:g_itName[MAX_ITEMS][64];
new String:g_itDesc[MAX_ITEMS][64];
new String:g_itParam[MAX_ITEMS][128];
new g_itPrice[MAX_ITEMS];
new g_itType[MAX_ITEMS];

new g_credits[MAXPLAYERS + 1];
new bool:g_owned[MAXPLAYERS + 1][MAX_ITEMS];
new bool:g_pending[MAXPLAYERS + 1];
new String:g_auth[MAXPLAYERS + 1][64];

public OnPluginStart() {
    RegConsoleCmd("sm_shop", Cmd_Shop, "Open shop");
    RegConsoleCmd("sm_store", Cmd_Shop, "Open shop");
    RegConsoleCmd("sm_credits", Cmd_Credits, "Show credits");
    RegConsoleCmd("sm_balance", Cmd_Credits, "Show credits");
    RegAdminCmd("sm_givecredit", Cmd_GiveCredit, ADMFLAG_GENERIC, "Give credits");
    HookEvent("player_spawn", Ev_Spawn);
    HookEvent("player_death", Ev_Death);
    HookEvent("round_end", Ev_RoundEnd);
    LoadItems();
}

LoadItems() {
    new String:path[256];
    BuildPath(Path_SM, path, 256, "configs/shop_items.cfg");
    new Handle:kv = CreateKeyValues("shop");
    if (!FileToKeyValues(kv, path)) {
        PrintToServer("[Shop] config missing, using defaults");
        CloseHandle(kv);
        return;
    }
    KvRewind(kv);
    if (KvGotoFirstSubKey(kv)) {
        do {
            new idx = g_itemCount;
            KvGetString(kv, "name", g_itName[idx], 64);
            KvGetString(kv, "desc", g_itDesc[idx], 64);
            KvGetString(kv, "param", g_itParam[idx], 128);
            g_itPrice[idx] = KvGetNum(kv, "price", 100);
            g_itType[idx] = KvGetNum(kv, "type", 0);
            g_itemCount++;
        } while (KvGotoNextKey(kv) && g_itemCount < MAX_ITEMS);
    }
    CloseHandle(kv);
    PrintToServer("[Shop] loaded %d items", g_itemCount);
}

LoadCredits(client) {
    g_credits[client] = START_CREDITS;
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/shop_credits.txt");
    new Handle:kv = CreateKeyValues("credits");
    if (FileToKeyValues(kv, path)) {
        KvRewind(kv);
        if (KvJumpToKey(kv, g_auth[client]))
            g_credits[client] = KvGetNum(kv, "credits", START_CREDITS);
    }
    CloseHandle(kv);
}

SaveCredits(client) {
    if (g_auth[client][0] == 0) return;
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/shop_credits.txt");
    new Handle:kv = CreateKeyValues("credits");
    FileToKeyValues(kv, path);
    KvRewind(kv);
    KvJumpToKey(kv, g_auth[client], true);
    KvSetNum(kv, "credits", g_credits[client]);
    KeyValuesToFile(kv, path);
    CloseHandle(kv);
}

LoadOwn(client) {
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/shop_own.txt");
    new Handle:kv = CreateKeyValues("own");
    if (FileToKeyValues(kv, path)) {
        KvRewind(kv);
        if (KvJumpToKey(kv, g_auth[client])) {
            for (new i = 0; i < g_itemCount; i++) {
                new String:flag[32];
                Format(flag, 32, "i%d", i);
                g_owned[client][i] = (KvGetNum(kv, flag, 0) == 1);
            }
        }
    }
    CloseHandle(kv);
}

SaveOwn(client) {
    if (g_auth[client][0] == 0) return;
    new String:path[256];
    BuildPath(Path_SM, path, 256, "data/shop_own.txt");
    new Handle:kv = CreateKeyValues("own");
    FileToKeyValues(kv, path);
    KvRewind(kv);
    KvJumpToKey(kv, g_auth[client], true);
    for (new i = 0; i < g_itemCount; i++) {
        new String:flag[32];
        Format(flag, 32, "i%d", i);
        KvSetNum(kv, flag, g_owned[client][i] ? 1 : 0);
    }
    KeyValuesToFile(kv, path);
    CloseHandle(kv);
}

public OnClientPutInServer(client) {
    if (!GetClientAuthId(client, AuthId_Steam2, g_auth[client], 64))
        Format(g_auth[client], 64, "uid:%d", GetClientUserId(client));
    LoadCredits(client);
    for (new i = 0; i < g_itemCount; i++)
        g_owned[client][i] = false;
    g_pending[client] = false;
    LoadOwn(client);
}

public OnClientDisconnect(client) {
    SaveCredits(client);
    SaveOwn(client);
}

public Action:Cmd_Shop(client, args) {
    if (client == 0) return Plugin_Handled;
    ShowShopMenu(client);
    return Plugin_Handled;
}

public Action:Cmd_Credits(client, args) {
    if (client == 0) return Plugin_Handled;
    PrintToChat(client, "\x04[Shop]\x01 You have\x03 %d credits", g_credits[client]);
    return Plugin_Handled;
}

public Action:Cmd_GiveCredit(client, args) {
    if (args < 2) {
        ReplyToCommand(client, "Usage: sm_givecredit <target> <amount>");
        return Plugin_Handled;
    }
    new String:targetArg[64], String:amtArg[16];
    GetCmdArg(1, targetArg, 64);
    GetCmdArg(2, amtArg, 16);
    new amount = StringToInt(amtArg);
    new target = FindTarget(client, targetArg);
    if (target == -1) return Plugin_Handled;
    g_credits[target] += amount;
    SaveCredits(target);
    ReplyToCommand(client, "[Shop] Gave %d credits", amount);
    return Plugin_Handled;
}

ShowShopMenu(client) {
    new Handle:menu = CreateMenu(Menu_Shop);
    SetMenuTitle(menu, "Shop - Balance: %d credits", g_credits[client]);
    new String:info[8], String:display[128];
    for (new i = 0; i < g_itemCount; i++) {
        Format(info, 8, "%d", i);
        if (g_owned[client][i])
            Format(display, 128, "[OWNED] %s", g_itName[i]);
        else
            Format(display, 128, "%s - %d cr", g_itName[i], g_itPrice[i]);
        AddMenuItem(menu, info, display, g_owned[client][i] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    }
    DisplayMenu(menu, client, 30);
}

public Menu_Shop(Handle:menu, MenuAction:action, client, param) {
    if (action == MenuAction_Select) {
        new String:info[8];
        GetMenuItem(menu, param, info, 8);
        new idx = StringToInt(info);
        if (g_owned[client][idx]) {
            PrintToChat(client, "\x04[Shop]\x01 Already owned.");
        } else if (g_credits[client] < g_itPrice[idx]) {
            PrintToChat(client, "\x04[Shop]\x01 Not enough credits! Need %d, have %d.",
                g_itPrice[idx], g_credits[client]);
            ShowShopMenu(client);
        } else {
            g_credits[client] -= g_itPrice[idx];
            g_owned[client][idx] = true;
            g_pending[client] = true;
            SaveCredits(client);
            SaveOwn(client);
            PrintToChat(client, "\x04[Shop]\x01 Purchased\x03 %s\x01! Balance: %d",
                g_itName[idx], g_credits[client]);
            PrintToChat(client, "\x04[Shop]\x01 Your skin will apply\x03 next round\x01!");
            ShowShopMenu(client);
        }
    } else if (action == MenuAction_End) {
        CloseHandle(menu);
    }
}

public Ev_Spawn(Handle:event, const String:name[], bool:dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (client <= 0 || !IsClientInGame(client)) return;
    CreateTimer(0.1, T_Apply, GetClientUserId(client));
}

public Action:T_Apply(Handle:timer, any:uid) {
    new client = GetClientOfUserId(uid);
    if (client > 0 && IsClientInGame(client) && IsPlayerAlive(client))
        ApplyItems(client);
}

public Ev_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
    // apply pending player skins at round end
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && g_pending[i]) {
            g_pending[i] = false;
            if (IsPlayerAlive(i))
                ApplyItems(i);
        }
    }
}

ApplyItems(client) {
    if (!IsPlayerAlive(client)) return;
    for (new i = 0; i < g_itemCount; i++) {
        if (!g_owned[client][i]) continue;
        if (g_itType[i] == 5) {
            SetEntityModel(client, g_itParam[i]);
        }
    }
}

public Ev_Death(Handle:event, const String:name[], bool:dontBroadcast) {
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    if (attacker <= 0 || attacker == victim || !IsClientInGame(attacker)) return;
    if (IsFakeClient(attacker)) return;
    // teamkill — no credits
    if (victim > 0 && IsClientInGame(victim) && GetClientTeam(attacker) == GetClientTeam(victim)) return;
    g_credits[attacker] += 25;
    if (g_credits[attacker] > 99999) g_credits[attacker] = 99999;
}
