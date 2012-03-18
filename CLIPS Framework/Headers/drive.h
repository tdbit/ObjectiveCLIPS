   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*                  DRIVE HEADER FILE                  */
   /*******************************************************/

/*************************************************************/
/* Purpose: Handles join network activity associated with    */
/*   with the addition of a data entity such as a fact or    */
/*   instance.                                               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_drive

#define _H_drive

#ifndef _H_expressn
#include "expressn.h"
#endif
#ifndef _H_match
#include "match.h"
#endif
#ifndef _H_network
#include "network.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DRIVE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   void                           NetworkAssert(void *,struct partialMatch *,struct joinNode *,int);
   void                           PNLDrive(void *,struct joinNode *,struct partialMatch *);
   CLIPS_BOOLEAN                        EvaluateJoinExpression(void *,struct expr *,struct partialMatch *,struct partialMatch *,struct joinNode *);

#endif





