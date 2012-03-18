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

#ifndef _H_objrtbin
#define _H_objrtbin

#if INSTANCE_PATTERN_MATCHING

#define OBJECTRETEBIN_DATA 34

struct objectReteBinaryData
  { 
   long AlphaNodeCount;
   long PatternNodeCount;
   OBJECT_ALPHA_NODE *AlphaArray;
   OBJECT_PATTERN_NODE *PatternArray;
  };

#define ObjectReteBinaryData(theEnv) ((struct objectReteBinaryData *) GetEnvironmentData(theEnv,OBJECTRETEBIN_DATA))


#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _OBJRTBIN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

LOCALE void SetupObjectPatternsBload(void *);

#endif

#endif



