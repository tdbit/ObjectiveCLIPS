   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.20  01/31/02          */
   /*                                                     */
   /*                 BLOAD HEADER FILE                   */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*      Brian L. Donnell                                     */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_bload
#define _H_bload

#ifndef _H_utility
#include "utility.h"
#endif
#ifndef _H_extnfunc
#include "extnfunc.h"
#endif
#ifndef _H_exprnbin
#include "exprnbin.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif
#ifndef _H_sysdep
#include "sysdep.h"
#endif
#ifndef _H_symblbin
#include "symblbin.h"
#endif

#define BLOAD_DATA 38

struct bloadData
  { 
   char *BinaryPrefixID;
   char *BinaryVersionID;
   struct FunctionDefinition **FunctionArray;
   int BloadActive;
   struct callFunctionItem *BeforeBloadFunctions;
   struct callFunctionItem *AfterBloadFunctions;
   struct callFunctionItem *ClearBloadReadyFunctions;
   struct callFunctionItem *AbortBloadFunctions;
  };

#define BloadData(theEnv) ((struct bloadData *) GetEnvironmentData(theEnv,BLOAD_DATA))

#ifdef LOCALE
#undef LOCALE
#endif
#ifdef _BLOAD_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define FunctionPointer(i) ((struct FunctionDefinition *) (((i) == -1L) ? NULL : BloadData(theEnv)->FunctionArray[i]))

#if ENVIRONMENT_API_ONLY
#define Bload(theEnv,a) EnvBload(theEnv,a)
#else
#define Bload(a) EnvBload(GetCurrentEnvironment(),a)
#endif

   LOCALE void                    InitializeBloadData(void *);
   LOCALE int                     BloadCommand(void *);
   LOCALE CLIPS_BOOLEAN                 EnvBload(void *,char *);
   LOCALE void                    BloadandRefresh(void *,long,unsigned,void (*)(void *,void *,long));
   LOCALE CLIPS_BOOLEAN                 Bloaded(void *);
   LOCALE void                    AddBeforeBloadFunction(void *,char *,void (*)(void *),int);
   LOCALE void                    AddAfterBloadFunction(void *,char *,void (*)(void *),int);
   LOCALE void                    AddBloadReadyFunction(void *,char *,int (*)(void),int);
   LOCALE void                    AddClearBloadReadyFunction(void *,char *,int (*)(void *),int);
   LOCALE void                    AddAbortBloadFunction(void *,char *,void (*)(void *),int);
   LOCALE void                    CannotLoadWithBloadMessage(void *,char *);

#endif

