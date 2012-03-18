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

#ifndef _H_genrcexe
#define _H_genrcexe

#if DEFGENERIC_CONSTRUCT

#include "genrcfun.h"
#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GENRCEXE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

LOCALE void GenericDispatch(void *,DEFGENERIC *,DEFMETHOD *,DEFMETHOD *,EXPRESSION *,DATA_OBJECT *);
LOCALE void UnboundMethodErr(void *);
LOCALE CLIPS_BOOLEAN IsMethodApplicable(void *,DEFMETHOD *);

#if IMPERATIVE_METHODS
LOCALE int NextMethodP(void *);
LOCALE void CallNextMethod(void *,DATA_OBJECT *);
LOCALE void CallSpecificMethod(void *,DATA_OBJECT *);
LOCALE void OverrideNextMethod(void *,DATA_OBJECT *);
#endif

LOCALE void GetGenericCurrentArgument(void *,DATA_OBJECT *);

#ifndef _GENRCEXE_SOURCE_
#endif

#endif

#endif




