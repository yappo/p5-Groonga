#ifndef  __PERL_GROONGA_H__
#define  __PERL_GROONGA_H__
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <groonga.h>

typedef struct {
  grn_ctx         *ctx;
  grn_obj         *table;
} PerlGroonga_Table;

typedef struct {
  grn_ctx         *ctx;
  grn_pat         *pat;
} PerlGroonga_PatriciaTrie;

typedef struct {
  grn_ctx         *ctx;
  grn_obj         *db;
} PerlGroonga_DB;

#endif /* __PERL_GROONGA_H__ */
