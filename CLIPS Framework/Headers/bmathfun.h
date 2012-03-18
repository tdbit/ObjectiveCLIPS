   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*             BASIC MATH FUNCTIONS MODULE             */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_bmathfun

#define _H_bmathfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _BMATHFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define GetAutoFloatDividend(theEnv) EnvGetAutoFloatDividend(theEnv)
#define SetAutoFloatDividend(theEnv,a) EnvSetAutoFloatDividend(theEnv,a)
#else
#define GetAutoFloatDividend() EnvGetAutoFloatDividend(GetCurrentEnvironment())
#define SetAutoFloatDividend(a) EnvSetAutoFloatDividend(GetCurrentEnvironment(),a)
#endif

   LOCALE void                    BasicMathFunctionDefinitions(void *);
   LOCALE void                    AdditionFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MultiplicationFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    SubtractionFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    DivisionFunction(void *,DATA_OBJECT_PTR);
   LOCALE long                    DivFunction(void *);
   LOCALE CLIPS_BOOLEAN                 SetAutoFloatDividendCommand(void *);
   LOCALE CLIPS_BOOLEAN                 GetAutoFloatDividendCommand(void *);
   LOCALE CLIPS_BOOLEAN                 EnvGetAutoFloatDividend(void *);
   LOCALE CLIPS_BOOLEAN                 EnvSetAutoFloatDividend(void *,int);
   LOCALE long int                IntegerFunction(void *);
   LOCALE double                  FloatFunction(void *);
   LOCALE void                    AbsFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MinFunction(void *,DATA_OBJECT_PTR);
   LOCALE void                    MaxFunction(void *,DATA_OBJECT_PTR);

#endif




