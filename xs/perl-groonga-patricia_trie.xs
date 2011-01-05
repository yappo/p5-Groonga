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
        if (self->pat != NULL) {
            croak("Cannot create context. please close this context.");
        }
        self->pat = grn_pat_create(self->ctx, path_c, key_size, value_size, flags);
        RETVAL = self->pat ? 1 : 0;
    OUTPUT:
        RETVAL

int
open(PerlGroonga_PatriciaTrie *self, SV *path)
    CODE:
        const char *path_c = path==&PL_sv_undef ? NULL : SvPV_nolen(path);
        if (self->pat != NULL) {
            croak("Cannot create context. please close this context.");
        }
        self->pat = grn_pat_open(self->ctx, path_c);
        RETVAL = self->pat ? 1 : 0;
    OUTPUT:
        RETVAL

int
close(PerlGroonga_PatriciaTrie *self)
    CODE:
        grn_rc rc;

        if (self->pat == NULL) {
            croak("Cannot close context");
        }
        rc = grn_pat_close(self->ctx, self->pat);
        if (!rc)
            self->pat = NULL;
        RETVAL = rc ? 0 : 1;
    OUTPUT:
        RETVAL

int
remove(PerlGroonga_PatriciaTrie *self, SV *path)
    CODE:
        const char *path_c = path==&PL_sv_undef ? NULL : SvPV_nolen(path);
        grn_rc rc;
        if (self->pat != NULL) {
            croak("Cannot create context. please close this context.");
        }
        rc = grn_pat_remove(self->ctx, path_c);
        RETVAL = rc ? 0 : 1;
    OUTPUT:
        RETVAL

void
add(PerlGroonga_PatriciaTrie *self, SV *key, SV *value)
    PPCODE:
        const void *value_ptr;
        const char *key_c, *value_c;
        STRLEN key_size, value_size;
        grn_id id;
        int added;

        if (key == &PL_sv_undef) {
            croak("key invalid");
        } else {
            key_c = SvPV(key, key_size);
        }
        if (value == &PL_sv_undef) {
            croak("value invalid");
        } else {
            value_c = SvPV(value, value_size);
        }

        id = grn_pat_add(self->ctx, self->pat, key_c, key_size, &value_ptr, &added);
        memcpy(value_ptr, value_c, value_size +1); // XXX: I will think about '+1' later

        switch (GIMME_V) {
            case G_VOID:
                XSRETURN(0);
                break;
            case G_SCALAR:
                mXPUSHi( id );
                XSRETURN(1);
                break;
            default:
                mXPUSHi( id );
                mXPUSHi( added );
                XSRETURN(2);
                break;
        }

void
get(PerlGroonga_PatriciaTrie *self, SV *key)
    PPCODE:
        char *value;
        const char *key_c;
        STRLEN key_size;
        grn_id id;

        if (key == &PL_sv_undef) {
            croak("key invalid");
        } else {
            key_c = SvPV(key, key_size);
        }

        id = grn_pat_get(self->ctx, self->pat, key_c, key_size, &value);

        switch (GIMME_V) {
            case G_VOID:
                XSRETURN(0);
                break;
            case G_SCALAR:
                mXPUSHs( newSVpv(value, strlen(value)) ); // FIXME: for binary
                XSRETURN(1);
                break;
            default:
                mXPUSHs( newSVpv(value, strlen(value)) ); // FIXME: for binary
                mXPUSHi( id );
                XSRETURN(2);
                break;
        }

void
DESTROY(PerlGroonga_PatriciaTrie *self)
    CODE:
        if (self->pat != NULL)
            grn_pat_close(self->ctx, self->pat);
        if (grn_ctx_fin(self->ctx)) {
            croak("Cannot finalize context");
        }
        Safefree(self);

