   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*        FACT RETE ACCESS FUNCTIONS HEADER FILE       */
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

#ifndef _H_factrete

#define _H_factrete

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _FACTRETE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE CLIPS_BOOLEAN                        FactPNGetVar1(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactPNGetVar2(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactPNGetVar3(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactJNGetVar1(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactJNGetVar2(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactJNGetVar3(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactSlotLength(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactJNCompVars1(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactJNCompVars2(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactPNCompVars1(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactPNConstant1(void *,void *,DATA_OBJECT_PTR);
   LOCALE CLIPS_BOOLEAN                        FactPNConstant2(void *,void *,DATA_OBJECT_PTR);
   LOCALE int                            FactStoreMultifield(void *,void *,DATA_OBJECT_PTR);
   LOCALE unsigned short                 AdjustFieldPosition(void *,struct multifieldMarker *,
                                                             unsigned short,unsigned short,int *);

#endif


