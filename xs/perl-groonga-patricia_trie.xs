#include "perl-groonga.h"
#include "xshelper.h"
#include "xs_object_magic.h"

MODULE = Groonga::PatriciaTrie    PACKAGE = Groonga::PatriciaTrie  PREFIX = PerlGroonga_PatriciaTrie_

PROTOTYPES: DISABLED

SV*
new(const char *class, int flags=0)
    PREINIT:
        PerlGroonga_PatriciaTrie *pat;
    CODE:
        Newxz( pat, 1, PerlGroonga_PatriciaTrie );
        pat->ctx = grn_ctx_open(flags);
        if (!pat->ctx) {
            croak("Cannot initialize context object");
        }

        RETVAL = xs_object_magic_create(
            pat,
            gv_stashpv(class, 0)
        );
    OUTPUT: RETVAL

int
create(PerlGroonga_PatriciaTrie *self, SV *path, unsigned int key_size=0x1000, unsigned int value_size=0x1000, unsigned int flags=0)
    CODE:
        const char *path_c = path==&PL_sv_undef ? NULL : SvPV_nolen(path);
        self->pat = grn_pat_create(self->ctx, path_c, key_size, value_size, flags);
        RETVAL = self->pat ? 1 : 0;
    OUTPUT:
        RETVAL

void
DESTROY(PerlGroonga_PatriciaTrie *self)
    CODE:
        grn_pat_close(self->ctx, self->pat);
        if (grn_ctx_fin(self->ctx)) {
            croak("Cannot finalize context");
        }
        Safefree(self);

