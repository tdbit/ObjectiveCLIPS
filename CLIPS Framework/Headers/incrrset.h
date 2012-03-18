   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*            INCREMENTAL RESET HEADER FILE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides functionality for the incremental       */
/*   reset of the pattern and join networks when a new       */
/*   rule is added.                                          */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_incrrset

#define _H_incrrset

#ifndef _H_ruledef
#include "ruledef.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INCRRSET_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define GetIncrementalReset(theEnv) EnvGetIncrementalReset(theEnv)
#define SetIncrementalReset(theEnv,a) EnvSetIncrementalReset(theEnv,a)
#else
#define GetIncrementalReset() EnvGetIncrementalReset(GetCurrentEnvironment())
#define SetIncrementalReset(a) EnvSetIncrementalReset(GetCurrentEnvironment(),a)
#endif

   LOCALE void                           IncrementalReset(void *,struct defrule *);
   LOCALE CLIPS_BOOLEAN                        EnvGetIncrementalReset(void *);
   LOCALE CLIPS_BOOLEAN                        EnvSetIncrementalReset(void *,CLIPS_BOOLEAN);
   LOCALE int                            GetIncrementalResetCommand(void *);
   LOCALE int                            SetIncrementalResetCommand(void *);

#endif









