   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*               CLIPS Version 6.20  01/31/02          */
   /*                                                     */
   /*                                                     */
   /*******************************************************/

/*************************************************************/
/* Purpose: Message-passing support functions                */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Brian L. Donnell                                     */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*                                                           */
/*************************************************************/

#ifndef _H_msgpass
#define _H_msgpass

#define GetActiveInstance(theEnv) ((INSTANCE_TYPE *) GetNthMessageArgument(theEnv,0)->value)

#ifndef _H_object
#include "object.h"
#endif

typedef struct messageHandlerLink
  {
   HANDLER *hnd;
   struct messageHandlerLink *nxt;
  } HANDLER_LINK;

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _MSGPASS_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#if ENVIRONMENT_API_ONLY
#define Send(theEnv,a,b,c,d) EnvSend(theEnv,a,b,c,d)
#else
#define Send(a,b,c,d) EnvSend(GetCurrentEnvironment(),a,b,c,d)
#endif

   LOCALE void             DirectMessage(void *,SYMBOL_HN *,INSTANCE_TYPE *,
                                         DATA_OBJECT *,EXPRESSION *);
   LOCALE void             EnvSend(void *,DATA_OBJECT *,char *,char *,DATA_OBJECT *);
   LOCALE void             DestroyHandlerLinks(void *,HANDLER_LINK *);
   LOCALE void             SendCommand(void *,DATA_OBJECT *);
   LOCALE DATA_OBJECT     *GetNthMessageArgument(void *,int);

#if IMPERATIVE_MESSAGE_HANDLERS
   LOCALE int              NextHandlerAvailable(void *);
   LOCALE void             CallNextHandler(void *,DATA_OBJECT *);
#endif

   LOCALE void             FindApplicableOfName(void *,DEFCLASS *,HANDLER_LINK *[],
                                                HANDLER_LINK *[],SYMBOL_HN *);
   LOCALE HANDLER_LINK    *JoinHandlerLinks(void *,HANDLER_LINK *[],HANDLER_LINK *[],SYMBOL_HN *);

   LOCALE void             PrintHandlerSlotGetFunction(void *,char *,void *);
   LOCALE CLIPS_BOOLEAN          HandlerSlotGetFunction(void *,void *,DATA_OBJECT *);
   LOCALE void             PrintHandlerSlotPutFunction(void *,char *,void *);
   LOCALE CLIPS_BOOLEAN          HandlerSlotPutFunction(void *,void *,DATA_OBJECT *);
   LOCALE void             DynamicHandlerGetSlot(void *,DATA_OBJECT *);
   LOCALE void             DynamicHandlerPutSlot(void *,DATA_OBJECT *);

#endif







