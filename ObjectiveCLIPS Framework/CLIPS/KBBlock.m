//
//  KBBlock.m
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 3/2/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import "KBBlock.h"

#import <CLIPS/clips.h>
#include <FScript/FScript.h>
#include "KBEnvironment.h"

/* 
We transform an FScript CLIPS expression from something like this

[?item doSometingWith: ?value]

to

[:item :value | item doSomethingWith: value]

which can then later be executed by collecting the arguments in an NSArray
and calling [block valueWithArguments: array].

Blocks live as long as the environment and are cached by source code.
*/

@implementation KBBlock

+blockWithSrcData:(NSData*)data environment:(KBEnvironment*)env
{
    return [[[self alloc]initWithSrcData: data environment: env] autorelease];
}

-initWithSrcData:(NSData*)data environment:(KBEnvironment*)env
{
    if(self = [super init])
    {
        _environment = env;
        _argTypes = [NSMutableDictionary new];
        _src = [[@"[" stringByAppendingString: [NSString stringWithUTF8String: [data bytes]]]retain];
        @try
        {
            _block = [[self _compileBlock: [self _scanVariables: data]] retain];
        }
        @catch(NSException* ex)
        {
            [self autorelease];
            [ex raise];
        }
    }
    return self;
}

-(NSString*)description
{
    return _src;
}

-(void)dealloc
{
    [_block release];
    [_argTypes release];
    [_src release];
    [super dealloc];
}

-(NSData*)_scanVariables:(NSData*) data
{
    NSMutableData *blockData = [NSMutableData dataWithCapacity: ([data length] * 2)];
    char* ptr = (char*)[data bytes];
    char* end = ptr + [data length];
    while(ptr < end)
    { 
        char byte = *ptr++;
        if(byte == '?' || byte == '$')
        {
            unsigned short type;
            NSMutableData *varName = [NSMutableData dataWithCapacity: 128];
            char vstr[2] = { 0, 0 };
                
            if(byte == '?')
            {
                type = SF_VARIABLE;
            }
            else // must be a $
            {
                char q = *ptr++;
                if(q == '?')
                {
                    type = MF_VARIABLE;
                }
                else
                {
                    [NSException raise: @"Syntax Error" format: @"Malformed multifield variable - expected '?' at '%s'",ptr];
                }
            }
            while(ptr < end && (isalnum(*ptr) || ('_' == *ptr)))
            {
                [varName appendBytes: ptr++ length: 1];
            }
            
            // add the scanned name to the source code
            [blockData appendData: varName]; 
            // null terminate
            [varName appendBytes: &(vstr[1]) length:1];
            [self _addArgumentNamed: [NSString stringWithUTF8String: [varName bytes]] type: type];
        }
        else
        {
            [blockData appendBytes: &byte length: 1];
        }
    }
    // null terminated
    return blockData;
}

-(Block*)_compileBlock:(NSData*) src
{
    NSMutableData* blockData = [NSMutableData dataWithCapacity: [src length] * 2];
    NSArray* varNames = [_argTypes allKeys];
    int i, count = [varNames count];
    [blockData appendBytes: "[" length: 1];
    
    for(i = 0; i < count; ++i)
    {
        NSString* nm = [varNames objectAtIndex: i];
        [blockData appendBytes: ":" length: 1];
        [blockData appendBytes: [nm UTF8String] length: [nm length]];
        [blockData appendBytes: " " length: 1];
    }
    if(count)
    {
        [blockData appendBytes: "| " length: 2];
    }
    
    // add the rest of the src code
    [blockData appendData: src];
    NSString* str = [NSString stringWithUTF8String: [blockData bytes]];
    
    FSSystem *sys = [[_environment interpreter] objectForIdentifier:@"sys" found:NULL];
    Block *result = [sys blockFromString: str]; // May raise
    
    [result setInterpreter:[_environment interpreter]];
    return result;
}

-(KBEnvironment*)environment
{
    return _environment;
}

-(Block*)block
{
    return _block;
}

-(NSArray*)argumentNames
{
    return [[self block]argumentsNames];
}

-(int)argumentCount
{
    return [[self block]argumentCount];
}

-(void)_addArgumentNamed: (NSString*) str type: (unsigned short)t
{
    NSNumber* type = [_argTypes objectForKey:str];
    if(!type)
    {
        [_argTypes setObject: [NSNumber numberWithUnsignedShort: t] forKey: str];
    }
    else if([type unsignedShortValue] != t)
    {
        [NSException raise: @"Syntax Error" format:@"Variable '%@' referenced as both field and multifield",str];
    }
}

-(void)_bindCLIPSArguments:(void*) t
{
    struct expr* top = (struct expr*) t;
    void* theEnv = [_environment _impl];
    NSArray *names = [_block argumentsNames];
    int i, count = [names count];
    struct token varToken;
    struct expr *lastOne = 0;
    lastOne = top->argList = GenConstant(theEnv,EXTERNAL_ADDRESS,self);
    for(i = 0; i < count; ++i)
    {
        NSString* nm = [names objectAtIndex:i];
        varToken.type = [[_argTypes objectForKey: nm] unsignedShortValue];
        varToken.value = EnvAddSymbol(theEnv,(char*)[nm UTF8String]);
        lastOne->nextArg = GenConstant(theEnv,varToken.type,varToken.value);
        lastOne = lastOne->nextArg;        
    }
}

@end
