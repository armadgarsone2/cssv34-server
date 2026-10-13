/* memfix.c — رفع باگ بافر memcpy در سرور CSS v34
 *
 * مشکل: بعضی نسخه‌های srcds با باگ memcpy ری‌اینترپریت میشن و فرمان‌های کنسول
 * به شکل خراب (مثل "Unknown command ex/") اجرا میشن یا هنگ میکنن.
 *
 * راه‌حل: جایگزینی memcpy با memmove که با overlap مشکلی نداره.
 * اجرا با LD_PRELOAD میشه، نیازی به تغییر باینری نیست.
 *
 * کامپایل (32 بیتی):
 *   gcc -m32 -shared -fPIC -O2 -o memfix.so memfix.c
 *
 * استفاده:
 *   LD_PRELOAD=/path/memfix.so ./srcds_i486 ...
 */
#define _GNU_SOURCE
#include <string.h>
void *memcpy(void *dest, const void *src, size_t n) {
    return memmove(dest, src, n);
}
