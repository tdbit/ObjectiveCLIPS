   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.20  01/31/02          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Donnell                                     */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_genrcpsr
#define _H_genrcpsr

#if DEFGENERIC_CONSTRUCT && (! BLOAD_ONLY) && (! RUN_TIME)

#include "genrcfun.h"

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GENRCPSR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

LOCALE CLIPS_BOOLEAN ParseDefgeneric(void *,char *);
LOCALE CLIPS_BOOLEAN ParseDefmethod(void *,char *);
LOCALE DEFMETHOD *AddMethod(void *,DEFGENERIC *,DEFMETHOD *,int,unsigned,EXPRESSION *,
                            int,int,SYMBOL_HN *,EXPRESSION *,char *,int);
LOCALE void PackRestrictionTypes(void *,RESTRICTION *,EXPRESSION *);
LOCALE void DeleteTempRestricts(void *,EXPRESSION *);
LOCALE DEFMETHOD *FindMethodByRestrictions(DEFGENERIC *,EXPRESSION *,int,
                                           SYMBOL_HN *,int *);

#ifndef _GENRCPSR_SOURCE_
#endif

#endif

#endif



