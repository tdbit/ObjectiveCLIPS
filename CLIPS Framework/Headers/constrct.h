   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.21  06/15/03            */
   /*                                                     */
   /*                  CONSTRUCT MODULE                   */
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

#ifndef _H_constrct

#define _H_constrct

struct constructHeader;
struct construct;

#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_symbol
#include "symbol.h"
#endif

#include "userdata.h"

struct constructHeader
  {
   struct symbolHashNode *name;
   char *ppForm;
   struct defmoduleItemHeader *whichModule;
   long bsaveID;
   struct constructHeader *next;
   struct userData *usrData;
  };

#define CHS (struct constructHeader *)

struct construct
  {
   char *constructName;
   char *pluralName;
   int (*parseFunction)(void *,char *);
   void *(*findFunction)(void *,char *);
   struct symbolHashNode *(*getConstructNameFunction)(struct constructHeader *);
   char *(*getPPFormFunction)(void *,struct constructHeader *);
   struct defmoduleItemHeader *(*getModuleItemFunction)(struct constructHeader *);
   void *(*getNextItemFunction)(void *,void *);
   void (*setNextItemFunction)(struct constructHeader *,struct constructHeader *);
   CLIPS_BOOLEAN (*isConstructDeletableFunction)(void *,void *);
   int (*deleteFunction)(void *,void *);
   void (*freeFunction)(void *,void *);
   struct construct *next;
  };

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_scanner
#include "scanner.h"
#endif

#define CONSTRUCT_DATA 42

struct constructData
  { 
   int ClearReadyInProgress;
   int ClearInProgress;
   int ResetReadyInProgress;
   int ResetInProgress;
#if (! RUN_TIME) && (! BLOAD_ONLY)
   struct callFunctionItem   *ListOfSaveFunctions;
   CLIPS_BOOLEAN PrintWhileLoading;
   unsigned WatchCompilations;
#endif
   struct construct *ListOfConstructs;
   struct callFunctionItem *ListOfResetFunctions;
   struct callFunctionItem *ListOfClearFunctions;
   struct callFunctionItem *ListOfClearReadyFunctions;
   int Executing;
   int (*BeforeResetFunction)(void *);
   int CheckSyntaxMode;
  };

#define ConstructData(theEnv) ((struct constructData *) GetEnvironmentData(theEnv,CONSTRUCT_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _CONSTRCT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define Clear(theEnv) EnvClear(theEnv)
#define Reset(theEnv) EnvReset(theEnv)
#define Save(theEnv,a) EnvSave(theEnv,a)
#define RemoveClearFunction(theEnv,a) EnvRemoveClearFunction(theEnv,a)
#define RemoveResetFunction(theEnv,a) EnvRemoveResetFunction(theEnv,a)
#else
#define Clear() EnvClear(GetCurrentEnvironment())
#define Reset() EnvReset(GetCurrentEnvironment())
#define Save(a) EnvSave(GetCurrentEnvironment(),a)
#define RemoveClearFunction(a) EnvRemoveClearFunction(GetCurrentEnvironment(),a)
#define RemoveResetFunction(a) EnvRemoveResetFunction(GetCurrentEnvironment(),a)
#endif

   LOCALE void                           InitializeConstructData(void *);
   LOCALE int                            EnvSave(void *,char *);
   LOCALE CLIPS_BOOLEAN                        AddSaveFunction(void *,char *,void (*)(void *,void *,char *),int);
   LOCALE CLIPS_BOOLEAN                        RemoveSaveFunction(void *,char *);
   LOCALE void                           EnvReset(void *);
   LOCALE CLIPS_BOOLEAN                        EnvAddResetFunction(void *,char *,void (*)(void *),int);
   LOCALE CLIPS_BOOLEAN                        AddResetFunction(char *,void (*)(void),int);
   LOCALE CLIPS_BOOLEAN                        EnvRemoveResetFunction(void *,char *);
   LOCALE void                           EnvClear(void *);
   LOCALE CLIPS_BOOLEAN                        AddClearReadyFunction(void *,char *,int (*)(void *),int);
   LOCALE CLIPS_BOOLEAN                        RemoveClearReadyFunction(void *,char *);
   LOCALE CLIPS_BOOLEAN                        EnvAddClearFunction(void *,char *,void (*)(void *),int);
   LOCALE CLIPS_BOOLEAN                        AddClearFunction(char *,void (*)(void),int);
   LOCALE CLIPS_BOOLEAN                        EnvRemoveClearFunction(void *,char *);
   LOCALE struct construct              *AddConstruct(void *,char *,char *,
                                                      int (*)(void *,char *),
                                                      void *(*)(void *,char *),
                                                      SYMBOL_HN *(*)(struct constructHeader *),
                                                      char *(*)(void *,struct constructHeader *),
                                                      struct defmoduleItemHeader *(*)(struct constructHeader *),
                                                      void *(*)(void *,void *),
                                                      void (*)(struct constructHeader *,struct constructHeader *),
                                                      CLIPS_BOOLEAN (*)(void *,void *),
                                                      int (*)(void *,void *),
                                                      void (*)(void *,void *));
   LOCALE int                            RemoveConstruct(void *,char *);
   LOCALE void                           SetCompilationsWatch(void *,unsigned);
   LOCALE unsigned                       GetCompilationsWatch(void *);
   LOCALE void                           SetPrintWhileLoading(void *,CLIPS_BOOLEAN);
   LOCALE CLIPS_BOOLEAN                        GetPrintWhileLoading(void *);
   LOCALE int                            ExecutingConstruct(void *);
   LOCALE void                           SetExecutingConstruct(void *,int);
   LOCALE void                           InitializeConstructs(void *);
   LOCALE int                          (*SetBeforeResetFunction(void *,int (*)(void *)))(void *);
   LOCALE void                           OldGetConstructList(void *,DATA_OBJECT *,
                                                          void *(*)(void *,void *),
                                                          char *(*)(void *,void *));
   LOCALE void                           ResetCommand(void *);
   LOCALE void                           ClearCommand(void *);
   LOCALE CLIPS_BOOLEAN                        ClearReady(void *);
   LOCALE struct construct              *FindConstruct(void *,char *);
   LOCALE void                           DeinstallConstructHeader(void *,struct constructHeader *);
   LOCALE void                           DestroyConstructHeader(void *,struct constructHeader *);

#endif







