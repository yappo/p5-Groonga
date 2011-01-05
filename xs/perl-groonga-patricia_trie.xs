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

grn_rc
close(PerlGroonga_PatriciaTrie *self)
    CODE:
        grn_rc rc;

        if (self->pat == NULL) {
            croak("Cannot close context");
        }
        rc = grn_pat_close(self->ctx, self->pat);
        if (!rc)
            self->pat = NULL;
        RETVAL = rc;
    OUTPUT:
        RETVAL

grn_rc
remove(PerlGroonga_PatriciaTrie *self, SV *path)
    CODE:
        const char *path_c = path==&PL_sv_undef ? NULL : SvPV_nolen(path);
        grn_rc rc;
        if (self->pat != NULL) {
            croak("Cannot create context. please close this context.");
        }
        rc = grn_pat_remove(self->ctx, path_c);
        RETVAL = rc;
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

        id = grn_pat_add(self->ctx, self->pat, key_c, key_size, (void **) &value_ptr, &added);
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

        id = grn_pat_get(self->ctx, self->pat, key_c, key_size, (void **) &value);

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

grn_rc
delete(PerlGroonga_PatriciaTrie *self, SV *key)
    CODE:
        const char *key_c;
        STRLEN key_size;
        grn_rc rc;

        if (key == &PL_sv_undef) {
            croak("key invalid");
        } else {
            key_c = SvPV(key, key_size);
        }

        rc = grn_pat_delete(self->ctx, self->pat, key_c, key_size, NULL);
        RETVAL = rc;
    OUTPUT:
        RETVAL

void
scan(PerlGroonga_PatriciaTrie *self, SV *text, CV *callback)
    CODE:
        const char *text_c, *search_text;
        STRLEN text_size;
        long search_text_length;
        grn_pat_scan_hit hits[1024];
        char *termbuf;

        if (text == &PL_sv_undef) {
            croak("text invalid");
        } else {
            text_c = SvPV(text, text_size);
        }
        search_text        = text_c;
        search_text_length = text_size;

        Newxz( termbuf, text_size, char * );

        while (search_text_length > 0) {
            const char *rest;
            int i, n_hits;
            unsigned int previous_offset = 0;
            grn_pat *pat;
            pat = self->pat;

            n_hits = grn_pat_scan(self->ctx, self->pat, search_text, search_text_length, hits, sizeof(hits) / sizeof(*hits), &rest);

            for (i = 0; i < n_hits; i++) {
                SV *record, *term;
                int term_size;

                if (hits[i].offset < previous_offset)
                    continue;

                // slice term in search_text
                record = newSVpv(text_c + hits[i].offset, hits[i].length);

                // get term by record_id
                term_size = grn_pat_get_key(self->ctx, self->pat, hits[i].id, termbuf, text_size);
                if (term_size == 0)
                    croak("grn_id=%d is not found", hits[i].id);
                if (term_size > text_size)
                    croak("buffer over");
                termbuf[term_size] = '\0';
                term = newSVpv(termbuf, term_size);

                // call to callback
                {
                    dSP;
                    ENTER;
                    SAVETMPS;
                    PUSHMARK(SP);
                    XPUSHs(record);
                    XPUSHs(term);
                    mXPUSHi((int) hits[i].offset);
                    mXPUSHi((int) hits[i].length);
                    mXPUSHi((int) hits[i].id);
                    PUTBACK;

                    call_sv( (SV*)callback, G_SCALAR );

                    SPAGAIN;
                    PUTBACK;
                    FREETMPS;
                    LEAVE;
                }

                previous_offset = hits[i].offset;
            }
            search_text_length -= rest - search_text;
            search_text = rest;
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

