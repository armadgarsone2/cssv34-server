#pragma semicolon 1
#include <sourcemod>

public Plugin myinfo = {
    name = "Welcome and Ads",
    author = "Ali",
    description = "Welcome, rules and rotating ads",
    version = "1.0",
};

new g_adIndex = 0;
#define NUM_ADS 8

new String:g_ads[8][256];

public OnPluginStart() {
    strcopy(g_ads[0], 256, "\x04[AD]\x01 آی‌پی بازی: \x03147.185.221.215:19303\x01 - همین الان وصل شو!");
    strcopy(g_ads[1], 256, "\x04[AD]\x01 \x04!knife\x01 - چاقوی دلخواهت رو انتخاب کن (M9 / پروانه‌ای)");
    strcopy(g_ads[2], 256, "\x04[AD]\x01 \x04!shop\x01 - اسکین شخصی بخر، راند بعد اعمال می‌شود!");
    strcopy(g_ads[3], 256, "\x04[AD]\x01 با هر کشتن \x0325\x01 سکه می‌گیری!");
    strcopy(g_ads[4], 256, "\x04[AD]\x01 اسکین گان و نارنجک برای \x03همه بازیکنان\x01 رایگان است!");
    strcopy(g_ads[5], 256, "\x04[AD]\x01 برای دیدن قوانین: \x04!rules");
    strcopy(g_ads[6], 256, "\x04[AD]\x01 رتبه خودت رو ببین: \x04!rank\x01 | برترین‌ها: \x04!top");
    strcopy(g_ads[7], 256, "\x04[AD]\x01 رتبه تفکیکی: \x04!top sniper\x01 | \x04!top rifle\x01 | \x04!top knife");
    RegConsoleCmd("sm_rules", Cmd_Rules, "Server rules");
    CreateTimer(300.0, T_Ad, _, TIMER_REPEAT);
}

public OnClientPutInServer(client) {
    CreateTimer(5.0, T_Welcome, GetClientUserId(client));
}

public Action:T_Welcome(Handle:timer, any:uid) {
    new client = GetClientOfUserId(uid);
    if (client <= 0 || !IsClientInGame(client)) return Plugin_Stop;
    PrintToChat(client, " ");
    PrintToChat(client, " \x04*+*+*+*+*+*+*+*+*+*");
    PrintToChat(client, " \x03به سرور CS:S v34 خوش آمدید!");
    PrintToChat(client, " \x01آی‌پی بازی: \x04147.185.221.215:19303");
    PrintToChat(client, " \x01اسکین گان و نارنجک برای همه فعال است!");
    PrintToChat(client, " \x01خرید اسکین شخص: \x04!shop\x01 | انتخاب چاقو: \x04!knife");
    PrintToChat(client, " \x01رتبه: \x04!rank\x01 | برترین‌ها: \x04!top\x01 | قوانین: \x04!rules");
    PrintToChat(client, " \x04*+*+*+*+*+*+*+*+*+*");
    return Plugin_Stop;
}

public Action:Cmd_Rules(client, args) {
    if (client == 0) return Plugin_Handled;
    PrintToChat(client, " \x04* قوانین سرور *");
    PrintToChat(client, " \x011. \x03چیت، هک، اسکریپت و نرم\x01افزار جانبی غیرمجاز\x01 ممنوع - بن دائم");
    PrintToChat(client, " \x012. سوءاستفاده از \x03باگ و گلیچ\x01 برای برتری ممنوع");
    PrintToChat(client, " \x013. \x03توهین نژادی، شخصی و خانوادگی\x01 ممنوع");
    PrintToChat(client, " \x014. \x03اسپم در چت، میکروفون و صدا\x01 ممنوع");
    PrintToChat(client, " \x015. فحش و الفاظ رکیک ممنوع");
    PrintToChat(client, " \x016. \x03تیم\x01کیل عمدی ممنوع");
    PrintToChat(client, " \x017. ادعای ادمین بودن یا مزاحمت برای ادمین‌ها ممنوع");
    PrintToChat(client, " \x018. تبلیغ سرور، کانال یا گروه دیگر\x01 بدون اجازه ادمین ممنوع");
    PrintToChat(client, " \x019. تصمیمات ادمین‌ها \x03الزامی\x01 است - اعتراض در pv");
    PrintToChat(client, " \x0110. مزاحمت برای بازیکنان جدید و تازه‌وارد ممنوع");
    PrintToChat(client, " \x0111. بازی \x03جوانمردانه\x01 و رعایت نظم الزامی است");
    PrintToChat(client, " \x0112. مسئولیت اکانت بر عهده \x03خود بازیکن\x01 است");
    PrintToChat(client, " \x04موفق باشی! *");
    return Plugin_Handled;
}

public Action:T_Ad(Handle:timer) {
    PrintToChatAll(" ");
    PrintToChatAll("%s", g_ads[g_adIndex]);
    g_adIndex++;
    if (g_adIndex >= NUM_ADS) g_adIndex = 0;
    return Plugin_Continue;
}
