   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*          EXPRESSION OPERATIONS HEADER FILE          */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides utility routines for manipulating and   */
/*   examining expressions.                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Donnell                                     */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_exprnops

#define _H_exprnops

#ifndef _H_expressn
#include "expressn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _EXPRNOPS_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE CLIPS_BOOLEAN                        ConstantExpression(struct expr *);
   LOCALE void                           PrintExpression(void *,char *,struct expr *);
   LOCALE long                           ExpressionSize(struct expr *);
   LOCALE int                            CountArguments(struct expr *);
   LOCALE struct expr                   *CopyExpression(void *,struct expr *);
   LOCALE CLIPS_BOOLEAN                        ExpressionContainsVariables(struct expr *,int);
   LOCALE CLIPS_BOOLEAN                        IdenticalExpression(struct expr *,struct expr *);
   LOCALE struct expr                   *GenConstant(void *,unsigned short,void *);
#if ! RUN_TIME
   LOCALE int                            CheckArgumentAgainstRestriction(void *,struct expr *,int);
#endif
   LOCALE CLIPS_BOOLEAN                        ConstantType(int);
   LOCALE struct expr                   *CombineExpressions(void *,struct expr *,struct expr *);
   LOCALE struct expr                   *AppendExpressions(struct expr *,struct expr *);

#endif


