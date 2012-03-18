   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*            PREDICATE FUNCTIONS HEADER FILE          */
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

#ifndef _H_prdctfun

#define _H_prdctfun

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _PRDCTFUN_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           PredicateFunctionDefinitions(void *);
   LOCALE CLIPS_BOOLEAN                        EqFunction(void *);
   LOCALE CLIPS_BOOLEAN                        NeqFunction(void *);
   LOCALE CLIPS_BOOLEAN                        StringpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        SymbolpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        LexemepFunction(void *);
   LOCALE CLIPS_BOOLEAN                        NumberpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        FloatpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        IntegerpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        MultifieldpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        PointerpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        NotFunction(void *);
   LOCALE CLIPS_BOOLEAN                        AndFunction(void *);
   LOCALE CLIPS_BOOLEAN                        OrFunction(void *);
   LOCALE CLIPS_BOOLEAN                        LessThanOrEqualFunction(void *);
   LOCALE CLIPS_BOOLEAN                        GreaterThanOrEqualFunction(void *);
   LOCALE CLIPS_BOOLEAN                        LessThanFunction(void *);
   LOCALE CLIPS_BOOLEAN                        GreaterThanFunction(void *);
   LOCALE CLIPS_BOOLEAN                        NumericEqualFunction(void *);
   LOCALE CLIPS_BOOLEAN                        NumericNotEqualFunction(void *);
   LOCALE CLIPS_BOOLEAN                        OddpFunction(void *);
   LOCALE CLIPS_BOOLEAN                        EvenpFunction(void *);

#endif



