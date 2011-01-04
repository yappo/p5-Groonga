#include "perl-groonga.h"
#include "xshelper.h"

static int
PerlGroonga_PatriciaTrie_free( pTHX_ SV * const sv, MAGIC *const mg ) {
    PerlGroonga_PatriciaTrie* const ctx = (PerlGroonga_PatriciaTrie *) mg->mg_ptr;
    PERL_UNUSED_VAR(sv);
    assert( ctx != NULL );
    grn_pat_close(ctx->grn_ctx, ctx->ctx);
    grn_ctx_fin(ctx->grn_ctx);
    Safefree( ctx );
    return 1;
}

static MAGIC*
PerlGroonga_PatriciaTrie_mg_find(pTHX_ SV* const sv, const MGVTBL* const vtbl){
    MAGIC* mg;

    assert(sv   != NULL);
    assert(vtbl != NULL);

    for(mg = SvMAGIC(sv); mg; mg = mg->mg_moremagic){
        if(mg->mg_virtual == vtbl){
            assert(mg->mg_type == PERL_MAGIC_ext);
            return mg;
        }
    }

    croak("Groonga::PatriciaTrie: Invalid Groonga::PatriciaTrie object was passed to mg_find");
    return NULL; /* not reached */
}

static MGVTBL PerlGroonga_PatriciaTrie_vtbl = { /* for identity */
    NULL, /* get */
    NULL, /* set */
    NULL, /* len */
    NULL, /* clear */
    PerlGroonga_PatriciaTrie_free, /* free */
    NULL, /* copy */
    NULL, /* dup */
#ifdef MGf_LOCAL
    NULL,  /* local */
#endif
};


MODULE = Groonga::PatriciaTrie    PACKAGE = Groonga::PatriciaTrie  PREFIX = PerlGroonga_PatriciaTrie_

PROTOTYPES: DISABLED

PerlGroonga_PatriciaTrie *
PerlGroonga_PatriciaTrie_create (class, db_path, key_size = 0x1000, value_size = 1024, flags = 0);
        SV *class;
        const char* db_path;
        unsigned int key_size;
        unsigned int value_size;
        unsigned int flags;
    CODE:
        grn_ctx *grn_ctx;
        PerlGroonga_PatriciaTrie *pat;

        grn_ctx = grn_ctx_open(0);

        Newxz( pat, 1, PerlGroonga_PatriciaTrie );
        pat->grn_ctx = grn_ctx;
        pat->ctx     = grn_pat_create(grn_ctx, db_path, key_size, value_size, flags);

        RETVAL = pat;

    OUTPUT:
        RETVAL
