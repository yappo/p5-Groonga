#include "perl-groonga.h"
#include "xshelper.h"
#include "xs_object_magic.h"

MODULE = Groonga::DB    PACKAGE = Groonga::DB  PREFIX = PerlGroonga_DB_

PROTOTYPES: DISABLED

SV*
new(const char *class, int flags=0)
    PREINIT:
        PerlGroonga_DB *db;
    CODE:
        Newxz( db, 1, PerlGroonga_DB );
        db->ctx = grn_ctx_open(flags);
        if (!db->ctx) {
            croak("Cannot initialize context object");
        }

        RETVAL = xs_object_magic_create(
            db,
            gv_stashpv(class, 0)
        );
    OUTPUT: RETVAL

int
create(PerlGroonga_DB *self, SV *path)
    CODE:
        const char *path_c = path==&PL_sv_undef ? NULL : SvPV_nolen(path);
        grn_obj *db = grn_db_create(self->ctx, path_c, NULL);
        self->db = db;
        RETVAL = db ? 1 : 0;
    OUTPUT:
        RETVAL

int
open(PerlGroonga_DB *self, const char *path)
    CODE:
        grn_obj *db = grn_db_open(self->ctx, path);
        self->db = db;
        RETVAL = db ? 1 : 0;
    OUTPUT:
        RETVAL

void
DESTROY(PerlGroonga_DB* self)
    CODE:
        if (grn_ctx_fin(self->ctx)) {
            croak("Cannot finalize context");
        }
        Safefree(self);

