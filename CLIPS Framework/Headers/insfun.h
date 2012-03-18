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

#ifndef _H_insfun
#define _H_insfun

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif
#ifndef _H_moduldef
#include "moduldef.h"
#endif
#ifndef _H_object
#include "object.h"
#endif

#ifndef _H_pattern
#include "pattern.h"
#endif

typedef struct igarbage
  {
   INSTANCE_TYPE *ins;
   struct igarbage *nxt;
  } IGARBAGE;

#define INSTANCE_TABLE_HASH_SIZE 8191
#define InstanceSizeHeuristic(ins)      sizeof(INSTANCE_TYPE)

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define DecrementInstanceCount(theEnv,a) EnvDecrementInstanceCount(theEnv,a)
#define GetInstancesChanged(theEnv) EnvGetInstancesChanged(theEnv)
#define IncrementInstanceCount(theEnv,a) EnvIncrementInstanceCount(theEnv,a)
#define SetInstancesChanged(theEnv,a) EnvSetInstancesChanged(theEnv,a)
#else
#define DecrementInstanceCount(a) EnvDecrementInstanceCount(GetCurrentEnvironment(),a)
#define GetInstancesChanged() EnvGetInstancesChanged(GetCurrentEnvironment())
#define IncrementInstanceCount(a) EnvIncrementInstanceCount(GetCurrentEnvironment(),a)
#define SetInstancesChanged(a) EnvSetInstancesChanged(GetCurrentEnvironment(),a)
#endif

LOCALE void EnvIncrementInstanceCount(void *,void *);
LOCALE void EnvDecrementInstanceCount(void *,void *);
LOCALE void InitializeInstanceTable(void *);
LOCALE void CleanupInstances(void *);
LOCALE unsigned HashInstance(SYMBOL_HN *);
LOCALE void DestroyAllInstances(void *);
LOCALE void RemoveInstanceData(void *,INSTANCE_TYPE *);
LOCALE INSTANCE_TYPE *FindInstanceBySymbol(void *,SYMBOL_HN *);
LOCALE INSTANCE_TYPE *FindInstanceInModule(void *,SYMBOL_HN *,struct defmodule *,
                                           struct defmodule *,unsigned);
LOCALE INSTANCE_SLOT *FindInstanceSlot(void *,INSTANCE_TYPE *,SYMBOL_HN *);
LOCALE int FindInstanceTemplateSlot(void *,DEFCLASS *,SYMBOL_HN *);
LOCALE int EvaluateAndStoreInDataObject(void *,int,EXPRESSION *,DATA_OBJECT *);
LOCALE int PutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *,char *);
LOCALE int DirectPutSlotValue(void *,INSTANCE_TYPE *,INSTANCE_SLOT *,DATA_OBJECT *,DATA_OBJECT *);
LOCALE CLIPS_BOOLEAN ValidSlotValue(void *,DATA_OBJECT *,SLOT_DESC *,INSTANCE_TYPE *,char *);
LOCALE INSTANCE_TYPE *CheckInstance(void *,char *);
LOCALE void NoInstanceError(void *,char *,char *);
LOCALE void SlotExistError(void *,char *,char *);
LOCALE void StaleInstanceAddress(void *,char *,int);
LOCALE int EnvGetInstancesChanged(void *);
LOCALE void EnvSetInstancesChanged(void *,int);
LOCALE void PrintSlot(void *,char *,SLOT_DESC *,INSTANCE_TYPE *,char *);
LOCALE void PrintInstanceNameAndClass(void *,char *,INSTANCE_TYPE *,CLIPS_BOOLEAN);
LOCALE void PrintInstanceName(void *,char *,void *);
LOCALE void PrintInstanceLongForm(void *,char *,void *);

#if INSTANCE_PATTERN_MATCHING
LOCALE void DecrementObjectBasisCount(void *,void *);
LOCALE void IncrementObjectBasisCount(void *,void *);
LOCALE void MatchObjectFunction(void *,void *);
LOCALE CLIPS_BOOLEAN NetworkSynchronized(void *,void *);
#endif

#endif







