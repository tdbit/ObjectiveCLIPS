   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.21  06/15/03            */
   /*                                                     */
   /*                ENVRNMNT HEADER FILE                 */
   /*******************************************************/

/*************************************************************/
/* Purpose: Routines for supporting multiple environments.   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_envrnmnt
#define _H_envrnmnt

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _ENVRNMNT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define USER_ENVIRONMENT_DATA 70
#define MAXIMUM_ENVIRONMENT_POSITIONS 100

struct environmentCleanupFunction
  {
   char *name;
   void (*func)(void *);
   int priority;
   struct environmentCleanupFunction *next;
  };

struct environmentData
  {   
   unsigned int initialized : 1;
   unsigned long environmentIndex;
   void **theData;
   void (**cleanupFunctions)(void *);
   struct environmentCleanupFunction *listOfCleanupEnvironmentFunctions;
   struct environmentData *next;
  };

typedef struct environmentData ENVIRONMENT_DATA;
typedef struct environmentData * ENVIRONMENT_DATA_PTR;

#define GetEnvironmentData(theEnv,position) (((struct environmentData *) theEnv)->theData[position])
#define SetEnvironmentData(theEnv,position,value) (((struct environmentData *) theEnv)->theData[position] = value)

   LOCALE CLIPS_BOOLEAN                        AllocateEnvironmentData(void *,unsigned int,unsigned long,void (*)(void *));
   LOCALE CLIPS_BOOLEAN                        DeallocateEnvironmentData(void);
#if ALLOW_ENVIRONMENT_GLOBALS
   LOCALE void                           SetCurrentEnvironment(void *);
   LOCALE CLIPS_BOOLEAN                        SetCurrentEnvironmentByIndex(unsigned long);
   LOCALE void                          *GetEnvironmentByIndex(unsigned long);
   LOCALE void                          *GetCurrentEnvironment(void);
   LOCALE unsigned long                  GetEnvironmentIndex(void *);
#endif
   LOCALE void                          *CreateEnvironment(void);
   LOCALE CLIPS_BOOLEAN                        DestroyEnvironment(void *);
   LOCALE CLIPS_BOOLEAN                        AddEnvironmentCleanupFunction(void *,char *,void (*)(void *),int);

#endif

