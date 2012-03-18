   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*                 DEVELOPER HEADER FILE               */
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

#ifndef _H_developr
#define _H_developr

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _DEVELOPR_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           DeveloperCommands(void *);
   LOCALE void                           PrimitiveTablesInfo(void *);
   LOCALE void                           PrimitiveTablesUsage(void *);
   LOCALE void                           EnableGCHeuristics(void *);
   LOCALE void                           DisableGCHeuristics(void *);

#if DEFRULE_CONSTRUCT && DEFTEMPLATE_CONSTRUCT
   LOCALE void                           ShowFactPatternNetwork(void *);
#endif
#if INSTANCE_PATTERN_MATCHING
   LOCALE void                           PrintObjectPatternNetwork(void *);
#endif
#if OBJECT_SYSTEM
   LOCALE void                           InstanceTableUsage(void *);
#endif

#endif


