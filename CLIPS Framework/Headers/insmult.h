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

#ifndef _H_insmult
#define _H_insmult

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSMULT_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if (! RUN_TIME)
LOCALE void SetupInstanceMultifieldCommands(void *);
#endif

LOCALE void MVSlotReplaceCommand(void *,DATA_OBJECT *);
LOCALE void MVSlotInsertCommand(void *,DATA_OBJECT *);
LOCALE void MVSlotDeleteCommand(void *,DATA_OBJECT *);
LOCALE CLIPS_BOOLEAN DirectMVReplaceCommand(void *);
LOCALE CLIPS_BOOLEAN DirectMVInsertCommand(void *);
LOCALE CLIPS_BOOLEAN DirectMVDeleteCommand(void *);

#ifndef _INSMULT_SOURCE_
#endif

#endif



