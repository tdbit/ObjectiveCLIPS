//
//  FSInterpreter_CLIPSAdditions.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Tue Oct 01 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/clips.h>
#import <CLIPS/prcdrpsr.h>

#import <FScript/FScript.h>
#import "FSInterpreter_CLIPSAdditions.h"
#import "ObjectiveCLIPS.h"
#import "KBDataObject.h"
#import "KBBlock.h"

static void FScriptDo(void* theEnv, DATA_OBJECT_PTR returnValue);
static struct expr *FScriptParse(void *theEnv, struct expr *top, char *infile);

@interface NSData (CLIPSAdditions)

-(void)appendByte:(char) c;

@end

@implementation NSMutableData (CLIPSAdditions)

-(void)appendByte:(char) c
{
    char str[2] = { 0, 0 };
    str[0] = c;
    [self appendBytes: str length: 1];
}

@end

@implementation FSInterpreter (CLIPSAdditions)

-(void)_attachToEnvironment:(KBEnvironment*) env
{
    [self setObject: env forIdentifier: @"clips"];
    EnvDefineFunction2([env _impl],"[",'u',PTIEF FScriptDo,"FScriptDo","1*");
    AddFunctionParser([env _impl],"[",FScriptParse);
}

@end

#define FSCLIPS_MAX_ARGS 64

static void FScriptDo(void* theEnv, DATA_OBJECT_PTR returnValue)
{
    int argc                        = EnvRtnArgCount(theEnv);
    KBEnvironment* env              = [KBEnvironment environmentForImplementation: theEnv];
    Array*  args                    = [[Array arrayWithCapacity: argc] retain];
    KBBlock* block                  = nil;
    /* loop counter */
    int i;
    
    /* setup the default return value */
    returnValue->type = RVOID; /* void function? */

    @try
    {    
        /* get the block - it is the first argument */
        DATA_OBJECT blockValue = { 0, -1 };
        EnvRtnUnknown(theEnv,1,&blockValue);
        block = [NSObject objectForDataObject: &blockValue inEnvironment: env];
        
        /* now the arguments */
        for(i = 2; i <= argc; ++i)
        {
            DATA_OBJECT bindingValue = { 0, -1 };
            EnvRtnUnknown(theEnv,i,&bindingValue);
            id arg = [NSObject objectForDataObject: &bindingValue inEnvironment: env];
            [args addObject: arg];
        }
    
        // evaluate the block
        id result = [[block block] valueWithArguments: args];
        // set the result as the return value
        [result dataObject: returnValue inEnvironment: env];
    }
    @catch(NSException* ex)
    {
        NSString *msg = [NSString stringWithFormat: @"%@ :: %@ ",ex,block]; 
        SyntaxErrorMessage(theEnv,(char*)[msg UTF8String]);
    }
    @finally
    {
        /* we allocated memory for the argument list so give it back */
        [args release];
    }
}

static struct expr *FScriptParse(void *theEnv, struct expr *top, char *infile)
{
    char c;
    NSMutableData* data = [NSMutableData data];
    KBEnvironment* env = [KBEnvironment environmentForImplementation: theEnv]; 
    int parenCount = 1;
    
    while(parenCount && (c = EnvGetcRouter(theEnv,infile)) != -1)
    {
        parenCount += (c == '(');
        parenCount -= (c == ')');
        if(parenCount)
        {
            [data appendByte: c];
        }
    }
    
    // null terminate
    [data appendByte: 0];
   
    KBBlock* block = [env _cachedBlockForData: data];
    
    if(!block)
    {
        @try
        {
            // this will end up checking syntax of the block - may raise
            block = [KBBlock blockWithSrcData: data environment: env];
            [env _cacheBlock: block forData: data];
        }
        @catch(NSException* ex)
        {
            // bad things happened - report the error
            SyntaxErrorMessage(theEnv,(char*)[[ex description]UTF8String]);
            ReturnExpression(theEnv,top);
            return 0;
        }
    }
    /*
    else
    {
        NSLog(@"Cache hit on %s",[data bytes]);
    }
    */
    [block _bindCLIPSArguments: top];
    SavePPBuffer(theEnv,"[");
    SavePPBuffer(theEnv,(char*)[data bytes]);
    SavePPBuffer(theEnv,")");
    return top;
}

