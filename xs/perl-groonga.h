#ifndef  __PERL_GROONGA_H__
#define  __PERL_GROONGA_H__
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <groonga.h>

typedef struct {
  GRN_API grn_pat *ctx;
  grn_ctx         *grn_ctx;
} PerlGroonga_PatriciaTrie;

#endif /* __PERL_GROONGA_H__ */
