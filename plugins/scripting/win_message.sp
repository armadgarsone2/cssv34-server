#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {
    name = "Win Message",
    author = "Ali",
    description = "Round-win message, left-side credit",
    version = "3.0",
};

new Handle:g_HudSync;

public OnPluginStart() {
    HookEvent("round_end", Ev_RoundEnd);
    g_HudSync = CreateHudSynchronizer();
}

public Ev_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
    new winner = GetEventInt(event, "winner");
    new String:team[24];
    if (winner == 2)
        strcopy(team, 24, "\x02TERRORISTS");
    else if (winner == 3)
        strcopy(team, 24, "\x0BCOUNTER-TERRORISTS");
    else
        strcopy(team, 24, "\x08NOBODY");

    for (new i = 1; i <= MaxClients; i++) {
        if (!IsClientInGame(i) || IsFakeClient(i)) continue;

        // chat: winner only
        PrintToChat(i, " ");
        PrintToChat(i, " \x04*** \x01%s \x01wins the round! \x04***", team);
        PrintToChat(i, " ");

        // big credit on the LEFT side of the screen
        SetHudTextParams(0.05, 0.30, 5.0, 255, 200, 50, 255, 0, 6.0, 0.2, 0.5);
        ShowSyncHudText(i, g_HudSync, "Create by Ali Naderi");
    }

    PrintToServer("[Win] %s won the round - Create by Ali Naderi", team);
}
