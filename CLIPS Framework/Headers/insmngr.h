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

#ifndef _H_insmngr
#define _H_insmngr

#ifndef _H_object
#include "object.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _INSMNGR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

LOCALE void InitializeInstanceCommand(void *,DATA_OBJECT *);
LOCALE void MakeInstanceCommand(void *,DATA_OBJECT *);
LOCALE SYMBOL_HN *GetFullInstanceName(void *,INSTANCE_TYPE *);
LOCALE INSTANCE_TYPE *BuildInstance(void *,SYMBOL_HN *,DEFCLASS *,CLIPS_BOOLEAN);
LOCALE void InitSlotsCommand(void *,DATA_OBJECT *);
LOCALE CLIPS_BOOLEAN QuashInstance(void *,INSTANCE_TYPE *);

#if INSTANCE_PATTERN_MATCHING
LOCALE void InactiveInitializeInstance(void *,DATA_OBJECT *);
LOCALE void InactiveMakeInstance(void *,DATA_OBJECT *);
#endif

#endif







