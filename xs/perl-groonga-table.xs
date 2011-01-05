#include "perl-groonga.h"
#include "xshelper.h"

static int
PerlGroonga_Table_free( pTHX_ SV * const sv, MAGIC *const mg ) {
    PerlGroonga_Table* const ctx = (PerlGroonga_Table *) mg->mg_ptr;
    PERL_UNUSED_VAR(sv);
    assert( ctx != NULL );
    grn_ctx_fin(ctx->grn_ctx);
    Safefree( ctx );
    return 1;
}

static MAGIC*
PerlGroonga_Table_mg_find(pTHX_ SV* const sv, const MGVTBL* const vtbl){
    MAGIC* mg;

    assert(sv   != NULL);
    assert(vtbl != NULL);

    for(mg = SvMAGIC(sv); mg; mg = mg->mg_moremagic){
        if(mg->mg_virtual == vtbl){
            assert(mg->mg_type == PERL_MAGIC_ext);
            return mg;
        }
    }

    croak("Groonga::Table: Invalid Groonga::Table object was passed to mg_find");
    return NULL; /* not reached */
}

static MGVTBL PerlGroonga_Table_vtbl = { /* for identity */
    NULL, /* get */
    NULL, /* set */
    NULL, /* len */
    NULL, /* clear */
    PerlGroonga_Table_free, /* free */
    NULL, /* copy */
    NULL, /* dup */
#ifdef MGf_LOCAL
    NULL,  /* local */
#endif
};


MODULE = Groonga::Table    PACKAGE = Groonga::Table  PREFIX = PerlGroonga_Table_

PROTOTYPES: DISABLED

PerlGroonga_Table *
PerlGroonga_Table_create (class, name, path = NULL, flags = 0);
        SV *class;
        SV *name;
        const char *path;
        grn_obj_flags flags;
    CODE:
        grn_ctx *grn_ctx;
        grn_obj *key_type = NULL, *value_type = NULL;
        const char *name_val;
        STRLEN name_size;
        PerlGroonga_Table *table;

        name_val = SvPV(name, name_size);

        grn_ctx = grn_ctx_open(0);

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

        Newxz( table, 1, PerlGroonga_Table );
        table->grn_ctx = grn_ctx;
        table->ctx     = grn_table_create(grn_ctx, name_val, name_size, path, flags, key_type, value_type);

        RETVAL = table;

    OUTPUT:
        RETVAL

GRN_API grn_id
PerlGroonga_Table_add (self, key);
        PerlGroonga_Table *self;
        SV                *key;
    PPCODE:
        GRN_API grn_id id;
        const char *key_val;
        STRLEN key_size;
        int added;

        key_val = SvPV(key, key_size);
        warn("%d, %d, %d: %s (%d) \n", id, added, &added, key_val, key_size);
        id = grn_table_add(self->grn_ctx, self->ctx, key_val, key_size, &added);

        warn("%d, %d, %d\n", id, added, &added);
        mXPUSHi( id );
        mXPUSHi( added );

        XSRETURN(2);
