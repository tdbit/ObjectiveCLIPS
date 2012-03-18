   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.20  01/31/02            */
   /*                                                     */
   /*              COMMAND LINE HEADER FILE               */
   /*******************************************************/

/*************************************************************/
/* Purpose: Provides a set of routines for processing        */
/*   commands entered at the top level prompt.               */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_commline

#define _H_commline

#define COMMANDLINE_DATA 40

struct commandLineData
  { 
   int EvaluatingTopLevelCommand;
#if ! RUN_TIME
   char *CommandString;
   unsigned MaximumCharacters;
   int ParsingTopLevelCommand;
   char *BannerString;
   int (*EventFunction)(void *);
   int (*AfterPromptFunction)(void *);
#endif
  };

#define CommandLineData(theEnv) ((struct commandLineData *) GetEnvironmentData(theEnv,COMMANDLINE_DATA))

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _COMMLINE_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

   LOCALE void                           InitializeCommandLineData(void *);
   LOCALE int                            ExpandCommandString(void *,int);
   LOCALE void                           FlushCommandString(void *);
   LOCALE void                           SetCommandString(void *,char *);
   LOCALE void                           AppendCommandString(void *,char *);
   LOCALE char                          *GetCommandString(void *);
   LOCALE int                            CompleteCommand(char *);
   LOCALE void                           CommandLoop(void *);
   LOCALE void                           CommandLoopBatch(void *);
   LOCALE void                           PrintPrompt(void *);
   LOCALE void                           SetAfterPromptFunction(void *,int (*)(void *));
   LOCALE CLIPS_BOOLEAN                        RouteCommand(void *,char *,int);
   LOCALE int                          (*SetEventFunction(void *,int (*)(void *)))(void *);
   LOCALE CLIPS_BOOLEAN                        TopLevelCommand(void *);
   LOCALE void                           AppendNCommandString(void *,char *,unsigned);
   LOCALE void                           SetNCommandString(void *,char *,unsigned);
   LOCALE char                          *GetCommandCompletionString(void *,char *,unsigned);

#endif





