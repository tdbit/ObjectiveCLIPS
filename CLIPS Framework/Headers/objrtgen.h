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

#ifndef _H_objrtgen
#define _H_objrtgen

#if INSTANCE_PATTERN_MATCHING && (! RUN_TIME) && (! BLOAD_ONLY)

#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_reorder
#include "reorder.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _OBJRTGEN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void             ReplaceGetJNObjectValue(void *,EXPRESSION *,struct lhsParseNode *);
   LOCALE EXPRESSION      *GenGetJNObjectValue(void *,struct lhsParseNode *);
   LOCALE EXPRESSION      *ObjectJNVariableComparison(void *,struct lhsParseNode *,struct lhsParseNode *);
   LOCALE EXPRESSION      *GenObjectPNConstantCompare(void *,struct lhsParseNode *);
   LOCALE void             ReplaceGetPNObjectValue(void *,EXPRESSION *,struct lhsParseNode *);
   LOCALE EXPRESSION      *GenGetPNObjectValue(void *,struct lhsParseNode *); 
   LOCALE EXPRESSION      *ObjectPNVariableComparison(void *,struct lhsParseNode *,struct lhsParseNode *);
   LOCALE void             GenObjectLengthTest(void *,struct lhsParseNode *);
   LOCALE void             GenObjectZeroLengthTest(void *,struct lhsParseNode *);

#endif

#endif




