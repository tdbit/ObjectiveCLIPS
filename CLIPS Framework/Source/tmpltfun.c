   /*******************************************************/
   /*      "C" Language Integrated Production System      */
   /*                                                     */
   /*             CLIPS Version 6.23  01/31/05            */
   /*                                                     */
   /*             DEFTEMPLATE FUNCTIONS MODULE            */
   /*******************************************************/

/*************************************************************/
/* Purpose: Implements the modify and duplicate functions.   */
/*                                                           */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*                                                           */
/* Revision History:                                         */
/*      6.23: Correction for FalseSymbol/TrueSymbol. DR0859  */
/*                                                           */
/*************************************************************/

#define _TMPLTFUN_SOURCE_

#include "setup.h"

#if DEFTEMPLATE_CONSTRUCT

#include <stdio.h>
#define _STDIO_INCLUDED_
#include <string.h>

#include "constant.h"
#include "memalloc.h"
#include "symbol.h"
#include "scanner.h"
#include "exprnpsr.h"
#include "envrnmnt.h"
#include "argacces.h"
#include "router.h"
#include "cstrnchk.h"
#include "default.h"
#include "factmngr.h"
#include "commline.h"
#include "factrhs.h"
#include "modulutl.h"
#include "reorder.h"
#include "tmpltdef.h"
#include "tmpltlhs.h"
#include "tmpltutl.h"
#include "tmpltrhs.h"

#include "tmpltfun.h"

/***************************************/
/* LOCAL INTERNAL FUNCTION DEFINITIONS */
/***************************************/

   static void                    DuplicateModifyCommand(void *,int,DATA_OBJECT_PTR);
#if (! RUN_TIME) && (! BLOAD_ONLY)
   static struct expr            *ModAndDupParse(void *,struct expr *,char *,char *);
   static SYMBOL_HN              *FindTemplateForFactAddress(SYMBOL_HN *,struct lhsParseNode *);
#endif

/****************************************************************/
/* DeftemplateFunctions: Initializes the deftemplate functions. */
/****************************************************************/
globle void DeftemplateFunctions(
  void *theEnv)
  {
#if ! RUN_TIME
   EnvDefineFunction(theEnv,"modify",'u', PTIEF ModifyCommand,"ModifyCommand");
   EnvDefineFunction(theEnv,"duplicate",'u', PTIEF DuplicateCommand,"DuplicateCommand");

#if (! BLOAD_ONLY)
   AddFunctionParser(theEnv,"modify",ModifyParse);
   AddFunctionParser(theEnv,"duplicate",DuplicateParse);
#endif
   FuncSeqOvlFlags(theEnv,"modify",FALSE,FALSE);
   FuncSeqOvlFlags(theEnv,"duplicate",FALSE,FALSE);
#else
#if MAC_MCW || IBM_MCW || MAC_XCD
#pragma unused(theEnv)
#endif
#endif
  }

/*********************************************************************/
/* ModifyCommand: H/L access routine for the modify command. Calls   */
/*   the DuplicateModifyCommand function to perform the actual work. */
/*********************************************************************/
globle void ModifyCommand(
  void *theEnv,
  DATA_OBJECT_PTR returnValue)
  {
   DuplicateModifyCommand(theEnv,TRUE,returnValue);
  }

/***************************************************************************/
/* DuplicateCommand: H/L access routine for the duplicate command. Calls   */
/*   the DuplicateModifyCommand function to perform the actual work.       */
/***************************************************************************/
globle void DuplicateCommand(
  void *theEnv,
  DATA_OBJECT_PTR returnValue)
  {
   DuplicateModifyCommand(theEnv,FALSE,returnValue);
  }

/***************************************************************/
/* DuplicateModifyCommand: Implements the duplicate and modify */
/*   commands. The fact being duplicated or modified is first  */
/*   copied to a new fact. Replacements to the fields of the   */
/*   new fact are then made. If a modify command is being      */
/*   performed, the original fact is retracted. Lastly, the    */
/*   new fact is asserted.                                     */
/***************************************************************/
static void DuplicateModifyCommand(
  void *theEnv,
  int retractIt,
  DATA_OBJECT_PTR returnValue)
  {
   long int factNum;
   struct fact *oldFact, *newFact, *theFact;
   struct expr *testPtr;
   DATA_OBJECT computeResult;
   struct deftemplate *templatePtr;
   struct templateSlot *slotPtr;
   int i, position, found;

   /*===================================================*/
   /* Set the default return value to the symbol FALSE. */
   /*===================================================*/

   SetpType(returnValue,SYMBOL);
   SetpValue(returnValue,EnvFalseSymbol(theEnv));

   /*==================================================*/
   /* Evaluate the first argument which is used to get */
   /* a pointer to the fact to be modified/duplicated. */
   /*==================================================*/

   testPtr = GetFirstArgument();
   EvaluateExpression(theEnv,testPtr,&computeResult);

   /*==============================================================*/
   /* If an integer is supplied, then treat it as a fact-index and */
   /* search the fact-list for the fact with that fact-index.      */
   /*==============================================================*/

   if (computeResult.type == INTEGER)
     {
      factNum = ValueToLong(computeResult.value);
      if (factNum < 0)
        {
         if (retractIt) ExpectedTypeError2(theEnv,"modify",1);
         else ExpectedTypeError2(theEnv,"duplicate",1);
         SetEvaluationError(theEnv,TRUE);
         return;
        }

      oldFact = (struct fact *) EnvGetNextFact(theEnv,NULL);
      while (oldFact != NULL)
        {
         if (oldFact->factIndex == factNum)
           { break; }
         else
           { oldFact = oldFact->nextFact; }
        }

      if (oldFact == NULL)
        {
         char tempBuffer[20];
         sprintf(tempBuffer,"f-%ld",factNum);
         CantFindItemErrorMessage(theEnv,"fact",tempBuffer);
         return;
        }
     }

   /*==========================================*/
   /* Otherwise, if a pointer is supplied then */
   /* no lookup is required.                   */
   /*==========================================*/

   else if (computeResult.type == FACT_ADDRESS)
     { oldFact = (struct fact *) computeResult.value; }

   /*===========================================*/
   /* Otherwise, the first argument is invalid. */
   /*===========================================*/

   else
     {
      if (retractIt) ExpectedTypeError2(theEnv,"modify",1);
      else ExpectedTypeError2(theEnv,"duplicate",1);
      SetEvaluationError(theEnv,TRUE);
      return;
     }

   /*==================================*/
   /* See if it is a deftemplate fact. */
   /*==================================*/

   templatePtr = oldFact->whichDeftemplate;

   if (templatePtr->implied) return;

   /*================================================================*/
   /* Duplicate the values from the old fact (skipping multifields). */
   /*================================================================*/

   newFact = (struct fact *) CreateFactBySize(theEnv,oldFact->theProposition.multifieldLength);
   newFact->whichDeftemplate = templatePtr;
   for (i = 0; i < (int) oldFact->theProposition.multifieldLength; i++)
     {
      newFact->theProposition.theFields[i].type = oldFact->theProposition.theFields[i].type;
      if (newFact->theProposition.theFields[i].type != MULTIFIELD)
        { newFact->theProposition.theFields[i].value = oldFact->theProposition.theFields[i].value; }
      else
        { newFact->theProposition.theFields[i].value = NULL; }
     }

   /*========================*/
   /* Start replacing slots. */
   /*========================*/

   testPtr = testPtr->nextArg;
   while (testPtr != NULL)
     {
      /*============================================================*/
      /* If the slot identifier is an integer, then the slot was    */
      /* previously identified and its position within the template */
      /* was stored. Otherwise, the position of the slot within the */
      /* deftemplate has to be determined by comparing the name of  */
      /* the slot against the list of slots for the deftemplate.    */
      /*============================================================*/

      if (testPtr->type == INTEGER)
        { position = (int) ValueToLong(testPtr->value); }
      else
        {
         found = FALSE;
         position = 0;
         slotPtr = templatePtr->slotList;
         while (slotPtr != NULL)
           {
            if (slotPtr->slotName == (SYMBOL_HN *) testPtr->value)
              {
               found = TRUE;
               slotPtr = NULL;
              }
            else
              {
               slotPtr = slotPtr->next;
               position++;
              }
           }

         if (! found)
           {
            InvalidDeftemplateSlotMessage(theEnv,ValueToString(testPtr->value),
                                          ValueToString(templatePtr->header.name));
            SetEvaluationError(theEnv,TRUE);
            ReturnFact(theEnv,newFact);
            return;
           }
        }

      /*===================================================*/
      /* If a single field slot is being replaced, then... */
      /*===================================================*/

      if (newFact->theProposition.theFields[position].type != MULTIFIELD)
        {
         /*======================================================*/
         /* If the list of values to store in the slot is empty  */
         /* or contains more than one member than an error has   */
         /* occured because a single field slot can only contain */
         /* a single value.                                      */
         /*======================================================*/

         if ((testPtr->argList == NULL) ? TRUE : (testPtr->argList->nextArg != NULL))
           {
            MultiIntoSingleFieldSlotError(theEnv,GetNthSlot(templatePtr,position),templatePtr);
            ReturnFact(theEnv,newFact);
            return;
           }

         /*===================================================*/
         /* Evaluate the expression to be stored in the slot. */
         /*===================================================*/

         EvaluateExpression(theEnv,testPtr->argList,&computeResult);
         SetEvaluationError(theEnv,FALSE);

         /*====================================================*/
         /* If the expression evaluated to a multifield value, */
         /* then an error occured since a multifield value can */
         /* not be stored in a single field slot.              */
         /*====================================================*/

         if (computeResult.type == MULTIFIELD)
           {
            ReturnFact(theEnv,newFact);
            MultiIntoSingleFieldSlotError(theEnv,GetNthSlot(templatePtr,position),templatePtr);
            return;
           }

         /*=============================*/
         /* Store the value in the slot */
         /*=============================*/

         newFact->theProposition.theFields[position].type =
            computeResult.type;
         newFact->theProposition.theFields[position].value =
            computeResult.value;
        }

      /*=================================*/
      /* Else replace a multifield slot. */
      /*=================================*/

      else
        {
         /*======================================*/
         /* Determine the new value of the slot. */
         /*======================================*/

         StoreInMultifield(theEnv,&computeResult,testPtr->argList,FALSE);
         SetEvaluationError(theEnv,FALSE);

         /*=============================*/
         /* Store the value in the slot */
         /*=============================*/

         newFact->theProposition.theFields[position].type =
            computeResult.type;
         newFact->theProposition.theFields[position].value =
            computeResult.value;
        }

      testPtr = testPtr->nextArg;
     }

   /*=====================================*/
   /* Copy the multifield values from the */
   /* old fact that were not replaced.    */
   /*=====================================*/

   for (i = 0; i < (int) oldFact->theProposition.multifieldLength; i++)
     {
      if ((newFact->theProposition.theFields[i].type == MULTIFIELD) &&
          (newFact->theProposition.theFields[i].value == NULL))

        {
         newFact->theProposition.theFields[i].value =
            CopyMultifield(theEnv,(struct multifield *) oldFact->theProposition.theFields[i].value);
        }
     }

   /*======================================*/
   /* Perform the duplicate/modify action. */
   /*======================================*/

   if (retractIt) EnvRetract(theEnv,oldFact);
   theFact = (struct fact *) EnvAssert(theEnv,newFact);

   /*========================================*/
   /* The asserted fact is the return value. */
   /*========================================*/

   if (theFact != NULL)
     {
      SetpDOBegin(returnValue,1);
      SetpDOEnd(returnValue,theFact->theProposition.multifieldLength);
      SetpType(returnValue,FACT_ADDRESS);
      SetpValue(returnValue,(void *) theFact);
     }

   return;
  }

#if (! RUN_TIME) && (! BLOAD_ONLY)

/***************************************************************/
/* UpdateModifyDuplicate: Changes the modify/duplicate command */
/*   found on the RHS of a rule such that the positions of the */
/*   slots for replacement are stored rather than the slot     */
/*   name which allows quicker replacement of slots. This      */
/*   substitution can only take place when the deftemplate     */
/*   type is known (i.e. if a fact-index is used you don't     */
/*   know which type of deftemplate is going to be replaced    */
/*   until you actually do the replacement of slots).          */
/***************************************************************/
globle CLIPS_BOOLEAN UpdateModifyDuplicate(
  void *theEnv,
  struct expr *top,
  char *name,
  void *vTheLHS)
  {
   struct expr *functionArgs, *tempArg;
   SYMBOL_HN *templateName;
   struct deftemplate *theDeftemplate;
   struct templateSlot *slotPtr;
   short position;

   /*========================================*/
   /* Determine the fact-address or index to */
   /* be retracted by the modify command.    */
   /*========================================*/

   functionArgs = top->argList;
   if (functionArgs->type == SF_VARIABLE)
     {
      templateName = FindTemplateForFactAddress((SYMBOL_HN *) functionArgs->value,
                                                (struct lhsParseNode *) vTheLHS);
      if (templateName == NULL) return(TRUE);
     }
   else
     { return(TRUE); }

   /*========================================*/
   /* Make sure that the fact being modified */
   /* has a corresponding deftemplate.       */
   /*========================================*/

   theDeftemplate = (struct deftemplate *)
                    LookupConstruct(theEnv,DeftemplateData(theEnv)->DeftemplateConstruct,
                                    ValueToString(templateName),
                                    FALSE);

   if (theDeftemplate == NULL) return(TRUE);

   if (theDeftemplate->implied) return(TRUE);

   /*=============================================================*/
   /* Make sure all the slot names are valid for the deftemplate. */
   /*=============================================================*/

   tempArg = functionArgs->nextArg;
   while (tempArg != NULL)
     {
      /*======================*/
      /* Does the slot exist? */
      /*======================*/

      if ((slotPtr = FindSlot(theDeftemplate,(SYMBOL_HN *) tempArg->value,&position)) == NULL)
        {
         InvalidDeftemplateSlotMessage(theEnv,ValueToString(tempArg->value),
                                       ValueToString(theDeftemplate->header.name));
         return(FALSE);
        }

      /*=========================================================*/
      /* Is a multifield value being put in a single field slot? */
      /*=========================================================*/

      if (slotPtr->multislot == FALSE)
        {
         if (tempArg->argList == NULL)
           {
            SingleFieldSlotCardinalityError(theEnv,slotPtr->slotName->contents);
            return(FALSE);
           }
         else if (tempArg->argList->nextArg != NULL)
           {
            SingleFieldSlotCardinalityError(theEnv,slotPtr->slotName->contents);
            return(FALSE);
           }
         else if ((tempArg->argList->type == MF_VARIABLE) ||
                  ((tempArg->argList->type == FCALL) ?
                   (((struct FunctionDefinition *) tempArg->argList->value)->returnValueType == 'm') :
                      FALSE))
           {
            SingleFieldSlotCardinalityError(theEnv,slotPtr->slotName->contents);
            return(FALSE);
           }
        }

      /*======================================*/
      /* Are the slot restrictions satisfied? */
      /*======================================*/

      if (CheckRHSSlotTypes(theEnv,tempArg->argList,slotPtr,name) == 0)
        return(FALSE);

      /*=============================================*/
      /* Replace the slot with the integer position. */
      /*=============================================*/

      tempArg->type = INTEGER;
      tempArg->value = (void *) EnvAddLong(theEnv,(long) (FindSlotPosition(theDeftemplate,(SYMBOL_HN *) tempArg->value) - 1));

      tempArg = tempArg->nextArg;
     }

   return(TRUE);
  }

/**************************************************/
/* FindTemplateForFactAddress: Searches for the   */
/*   deftemplate name associated with the pattern */
/*   to which a fact address has been bound.      */
/**************************************************/
static SYMBOL_HN *FindTemplateForFactAddress(
  SYMBOL_HN *factAddress,
  struct lhsParseNode *theLHS)
  {
   struct lhsParseNode *thePattern = NULL;

   /*===============================================*/
   /* Look through the LHS patterns for the pattern */
   /* which is bound to the fact address used by    */
   /* the modify/duplicate function.                */
   /*===============================================*/

   while (theLHS != NULL)
     {
      if (theLHS->value == (void *) factAddress)
        {
         thePattern = theLHS;
         theLHS = NULL;
        }
      else
        { theLHS = theLHS->bottom; }
     }

   if (thePattern == NULL) return(NULL);

   /*=====================================*/
   /* Verify that just a symbol is stored */
   /* as the first field of the pattern.  */
   /*=====================================*/

   thePattern = thePattern->right;
   if ((thePattern->type != SF_WILDCARD) || (thePattern->bottom == NULL))
     { return(NULL); }

   thePattern = thePattern->bottom;
   if ((thePattern->type != SYMBOL) ||
            (thePattern->right != NULL) ||
            (thePattern->bottom != NULL))
    { return(NULL); }

   /*==============================*/
   /* Return the deftemplate name. */
   /*==============================*/

   return((SYMBOL_HN *) thePattern->value);
  }

/*******************************************/
/* ModifyParse: Parses the modify command. */
/*******************************************/
globle struct expr *ModifyParse(
  void *theEnv,
  struct expr *top,
  char *logicalName)
  {
   return(ModAndDupParse(theEnv,top,logicalName,"modify"));
  }

/*************************************************/
/* DuplicateParse: Parses the duplicate command. */
/*************************************************/
globle struct expr *DuplicateParse(
  void *theEnv,
  struct expr *top,
  char *logicalName)
  {
   return(ModAndDupParse(theEnv,top,logicalName,"duplicate"));
  }

/*************************************************************/
/* ModAndDupParse: Parses the modify and duplicate commands. */
/*************************************************************/
static struct expr *ModAndDupParse(
  void *theEnv,
  struct expr *top,
  char *logicalName,
  char *name)
  {
   int error = FALSE;
   struct token theToken;
   struct expr *nextOne, *tempSlot;
   struct expr *newField, *firstField, *lastField;
   int printError;
   short done;

   /*==================================================================*/
   /* Parse the fact-address or index to the modify/duplicate command. */
   /*==================================================================*/

   SavePPBuffer(theEnv," ");
   GetToken(theEnv,logicalName,&theToken);

   if ((theToken.type == SF_VARIABLE) || (theToken.type == GBL_VARIABLE))
     { nextOne = GenConstant(theEnv,theToken.type,theToken.value); }
   else if (theToken.type == INTEGER)
     {
      if (! TopLevelCommand(theEnv))
        {
         PrintErrorID(theEnv,"TMPLTFUN",1,TRUE);
         EnvPrintRouter(theEnv,WERROR,"Fact-indexes can only be used by ");
         EnvPrintRouter(theEnv,WERROR,name);
         EnvPrintRouter(theEnv,WERROR," as a top level command.\n");
         ReturnExpression(theEnv,top);
         return(NULL);
        }

      nextOne = GenConstant(theEnv,INTEGER,theToken.value);
     }
   else
     {
      ExpectedTypeError2(theEnv,name,1);
      ReturnExpression(theEnv,top);
      return(NULL);
     }

   nextOne->nextArg = NULL;
   nextOne->argList = NULL;
   top->argList = nextOne;
   nextOne = top->argList;

   /*=======================================================*/
   /* Parse the remaining modify/duplicate slot specifiers. */
   /*=======================================================*/

   GetToken(theEnv,logicalName,&theToken);
   while (theToken.type != RPAREN)
     {
      PPBackup(theEnv);
      SavePPBuffer(theEnv," ");
      SavePPBuffer(theEnv,theToken.printForm);

      /*=================================================*/
      /* Slot definition begins with a left parenthesis. */
      /*=================================================*/

      if (theToken.type != LPAREN)
        {
         SyntaxErrorMessage(theEnv,"duplicate/modify function");
         ReturnExpression(theEnv,top);
         return(NULL);
        }

      /*=================================*/
      /* The slot name must be a symbol. */
      /*=================================*/

      GetToken(theEnv,logicalName,&theToken);
      if (theToken.type != SYMBOL)
        {
         SyntaxErrorMessage(theEnv,"duplicate/modify function");
         ReturnExpression(theEnv,top);
         return(NULL);
        }

      /*=================================*/
      /* Check for duplicate slot names. */
      /*=================================*/

      for (tempSlot = top->argList->nextArg;
           tempSlot != NULL;
           tempSlot = tempSlot->nextArg)
        {
         if (tempSlot->value == theToken.value)
           {
            AlreadyParsedErrorMessage(theEnv,"slot ",ValueToString(theToken.value));
            ReturnExpression(theEnv,top);
            return(NULL);
           }
        }

      /*=========================================*/
      /* Add the slot name to the list of slots. */
      /*=========================================*/

      nextOne->nextArg = GenConstant(theEnv,SYMBOL,theToken.value);
      nextOne = nextOne->nextArg;

      /*====================================================*/
      /* Get the values to be stored in the specified slot. */
      /*====================================================*/

      firstField = NULL;
      lastField = NULL;
      done = FALSE;
      while (! done)
        {
         SavePPBuffer(theEnv," ");
         newField = GetAssertArgument(theEnv,logicalName,&theToken,&error,
                                      RPAREN,FALSE,&printError);

         if (error)
           {
            if (printError) SyntaxErrorMessage(theEnv,"deftemplate pattern");
            ReturnExpression(theEnv,top);
            return(NULL);
           }

         if (newField == NULL)
           { done = TRUE; }

         if (lastField == NULL)
           { firstField = newField; }
         else
           { lastField->nextArg = newField; }
         lastField = newField;
        }

      /*================================================*/
      /* Slot definition ends with a right parenthesis. */
      /*================================================*/

      if (theToken.type != RPAREN)
        {
         SyntaxErrorMessage(theEnv,"duplicate/modify function");
         ReturnExpression(theEnv,top);
         ReturnExpression(theEnv,firstField);
         return(NULL);
        }
      else
        {
         PPBackup(theEnv);
         PPBackup(theEnv);
         SavePPBuffer(theEnv,")");
        }

      nextOne->argList = firstField;

      GetToken(theEnv,logicalName,&theToken);
     }

   /*================================================*/
   /* Return the parsed modify/duplicate expression. */
   /*================================================*/

   return(top);
  }

#endif /* (! RUN_TIME) && (! BLOAD_ONLY) */

#endif /* DEFTEMPLATE_CONSTRUCT */

