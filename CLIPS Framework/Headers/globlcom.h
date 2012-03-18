   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*            DEFGLOBAL COMMANDS HEADER FILE           */
   /*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Donnell                                     */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_globlcom
#define _H_globlcom

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GLOBLCOM_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define GetResetGlobals(theEnv) EnvGetResetGlobals(theEnv)
#define SetResetGlobals(theEnv,a) EnvSetResetGlobals(theEnv,a)
#define ShowDefglobals(theEnv,a,b) EnvShowDefglobals(theEnv,a,b)
#else
#define GetResetGlobals() EnvGetResetGlobals(GetCurrentEnvironment())
#define SetResetGlobals(a) EnvSetResetGlobals(GetCurrentEnvironment(),a)
#define ShowDefglobals(a,b) EnvShowDefglobals(GetCurrentEnvironment(),a,b)
#endif

   LOCALE void                           DefglobalCommandDefinitions(void *);
   LOCALE int                            SetResetGlobalsCommand(void *);
   LOCALE CLIPS_BOOLEAN                        EnvSetResetGlobals(void *,int);
   LOCALE int                            GetResetGlobalsCommand(void *);
   LOCALE CLIPS_BOOLEAN                        EnvGetResetGlobals(void *);
   LOCALE void                           ShowDefglobalsCommand(void *);
   LOCALE void                           EnvShowDefglobals(void *,char *,void *);

#endif

