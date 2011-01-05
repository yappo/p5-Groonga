#include "perl-groonga.h"
#include "xshelper.h"
#include "xs_object_magic.h"

MODULE = Groonga::Table    PACKAGE = Groonga::Table  PREFIX = PerlGroonga_Table_

PROTOTYPES: DISABLED

SV*
new(const char *class, int flags=0)
    PREINIT:
        PerlGroonga_Table *table;
    CODE:
        Newxz( table, 1, PerlGroonga_Table );
        table->ctx = grn_ctx_open(flags);
        if (!table->ctx) {
            croak("Cannot initialize context object");
        }

        RETVAL = xs_object_magic_create(
            table,
            gv_stashpv(class, 0)
        );
    OUTPUT: RETVAL

int
create (PerlGroonga_Table *self, SV *name, SV *path = NULL, grn_obj_flags flags = 0);
    CODE:
        const char *path_c = (path==&PL_sv_undef || path==NULL) ? NULL : SvPV_nolen(path);
        grn_ctx *grn_ctx;
        grn_obj *key_type = NULL, *value_type = NULL;
        const char *name_c;
        STRLEN name_size;

        warn("HOGE\n");
        name_c = SvPV(name, name_size);
        warn("W: %s\n", name_c);

        if (1) { // XXX: for DEBUG
            path  = NULL;
            flags = GRN_OBJ_TABLE_PAT_KEY;
            key_type = NULL;
            value_type = NULL;
            /*
            key_type = GRN_TABLE_HASH_KEY;	//GRN_TABLE_HASH_KEY;//grn_ctx_at(grn_ctx, GRN_DB_SHORT_TEXT);
            flags  = GRN_OBJ_TABLE_PAT_KEY;
            flags |= GRN_OBJ_PERSISTENT;
            */
        }
        warn("W: %s, %d, %s\n", name_c, name_size, path_c);

        self->table = grn_table_create(grn_ctx, name_c, name_size, path_c, flags, key_type, value_type);
        warn("W: %s\n", name_c);
        RETVAL = self->table ? 1 : 0;
    OUTPUT:
        RETVAL

GRN_API grn_id
add (PerlGroonga_Table *self, SV *key);
    PPCODE:
        GRN_API grn_id id;
        const char *key_c;
        STRLEN key_size;
        int added;

	if (key == &PL_sv_undef) {
            croak("key invalid");
	} else {
            key_c = SvPV(key, key_size);
        }
        warn("%d, %d, %d: %s (%d) \n", id, added, &added, key_c, key_size);
        id = grn_table_add(self->ctx, self->table, key_c, key_size, &added);

        warn("%d, %d, %d\n", id, added, &added);
        mXPUSHi( id );
        mXPUSHi( added );

        XSRETURN(2);

void
DESTROY(PerlGroonga_Table *self)
    CODE:
        if (grn_ctx_fin(self->ctx)) {
            croak("Cannot finalize context");
        }
        Safefree(self);

