#include "perl-groonga.h"
#include "xshelper.h"
#include <string.h>

void
PerlGroonga_Call_Boot (pTHX_ XSPROTO(subaddr), CV *cv, SV **mark)
{
    dSP;
    PUSHMARK(mark);
    (*subaddr)(aTHX_ cv);
    PUTBACK;
}

EXTERN_C XS(boot_Groonga__PatriciaTrie);
EXTERN_C XS(boot_Groonga__DB);

MODULE = Groonga    PACKAGE = Groonga  PREFIX = PerlGroonga_

BOOT:
    grn_init();
    PerlGroonga_Call_Boot(aTHX_ boot_Groonga__PatriciaTrie, cv, mark);
    PerlGroonga_Call_Boot(aTHX_ boot_Groonga__DB, cv, mark);

void
get_version(void)
    PPCODE:
        const char *version = grn_get_version();
        mXPUSHp(version, strlen(version));

void
get_package(void)
    PPCODE:
        const char *package = grn_get_package();
        mXPUSHp(package, strlen(package));


MODULE = Groonga    PACKAGE = Groonga::Constants

INCLUDE: const-xs.inc
