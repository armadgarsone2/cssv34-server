/* No-steam shim for libsteamvalidateuseridtickets_i486.so
 *
 * راه‌حل قطعی خطای «STEAM validation rejected» روی سرورهای CSS v34 بدون استیم.
 *
 * چرا: موتور (engine_i486.so) موقع ورود کلاینت no-steam، بلیط استیم رو از
 * کتابخانه libsteamvalidateuseridtickets میخواد. چون کلاینت no-steam بلیط
 * امضاشده Valve نمیفرسته و VPS هم راهی به سرور استیم نداره، همیشه رد میشه.
 *
 * راه‌حل: این کتابخانه رو جایگزین اصلی کن تا همیشه جواب «معتبر» (ESteamError=0)
 * رو برگردونه. خودِ رد کردن داخل موتور هم با پچ engine (پایین‌تر) خنثی میشه.
 *
 * کامپایل (باید 32 بیتی باشه):
 *   gcc -m32 -shared -fPIC -O2 -o libsteamvalidateuseridtickets_i486.so nosteam_shim.c
 *
 * نصب:
 *   cp bin/libsteamvalidateuseridtickets_i486.so bin/libsteamvalidateuseridtickets_i486.so.orig2
 *   cp libsteamvalidateuseridtickets_i486.so bin/
 */
#include <string.h>
#include <stdint.h>

typedef int ESteamError;

/* returns ESteamError */
ESteamError SteamInitializeUserIDTicketValidator(const char *a, const char *b,
        unsigned c, unsigned d, unsigned e, unsigned f, unsigned g) {
    (void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)g;
    return 0;
}

ESteamError SteamShutdownUserIDTicketValidator(void) { return 0; }

ESteamError SteamStartValidatingNewValveCDKey(void *a, void *b, unsigned c,
        unsigned d, void *e, void *f) {
    (void)a;(void)b;(void)c;(void)d;(void)e;(void)f;
    return 0;
}

/* pSteamGlobalUserID out param is 2nd arg (TSteamGlobalUserID* = 8 bytes) */
ESteamError SteamStartValidatingUserIDTicket(void *a, void *pSteamGlobalUserID,
        unsigned c, unsigned d) {
    (void)c;(void)d;
    /* Assign a plausible non-steam SteamID [U:1:1] so it isn't ID 0.
     * Layout of TSteamGlobalIDs (64-bit): low bits = account id (32);
     * universe/type/instance packed above. */
    if (pSteamGlobalUserID) {
        uint64_t id = 0;
        uint32_t acc = 1;
        uint64_t universe = 1;      /* k_EAccountUniversePublic */
        uint64_t type = 1;          /* k_EAccountTypeIndividual */
        uint64_t instance = 1;      /* desktop */
        id = (uint64_t)acc
           | (universe << 56)
           | (type << 52)
           | (instance << 44);
        memcpy(pSteamGlobalUserID, &id, 8);
    }
    (void)a;
    return 0;
}

/* Always "done & valid". Return 0. Fill optional out params safely. */
ESteamError SteamProcessOngoingUserIDTicketValidation(void *a, void *b,
        unsigned *pSteamIDPending, unsigned char *pbSDRPublicKey,
        unsigned c, void *d, unsigned char *e) {
    (void)a;(void)b;(void)c;(void)d;(void)e;
    if (pSteamIDPending) *pSteamIDPending = 0;
    return 0;
}

ESteamError SteamAbortOngoingUserIDTicketValidation(void *a, void *b) {
    (void)a;(void)b; return 0;
}

ESteamError SteamOptionalCleanUpAfterClientHasDisconnected(void *a, unsigned b) {
    (void)a;(void)b; return 0;
}

/* Must return a nonzero key length and write an encryption key.
 * Write a fixed 16-byte key so server proceeds; non-steam clients ignore it. */
ESteamError SteamGetEncryptionKeyToSendToNewClient(void *pvCB, void *pvKeyBuffer, unsigned uKeyLen) {
    (void)pvCB;
    if (pvKeyBuffer && uKeyLen >= 16) {
        unsigned char key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef,
                                 0xfe,0xdc,0xba,0x98,0x76,0x54,0x32,0x10};
        memcpy(pvKeyBuffer, key, 16);
        return 16; /* key size */
    }
    return 0;
}
