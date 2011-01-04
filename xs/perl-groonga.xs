#include "perl-groonga.h"
#include "xshelper.h"

void
PerlGroonga_Call_Boot (pTHX_ XSPROTO(subaddr), CV *cv, SV **mark)
{
    dSP;
    PUSHMARK(mark);
    (*subaddr)(aTHX_ cv);
    PUTBACK;
}

EXTERN_C XS(boot_Groonga__PatriciaTrie);

MODULE = Groonga    PACKAGE = Groonga  PREFIX = PerlGroonga_

BOOT:
    grn_init();

    PerlGroonga_Call_Boot(aTHX_ boot_Groonga__PatriciaTrie, cv, mark);
