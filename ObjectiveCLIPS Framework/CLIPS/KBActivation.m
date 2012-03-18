//
//  KBActivation.m
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 9/22/05.
//  Copyright 2005 Black Bag Operations Network. All rights reserved.
//

#import "KBActivation.h"
#import "KBRouter.h"
#import "KBRule.h"
#import <CLIPS/reteutil.h>
#import <CLIPS/factmngr.h>


@implementation KBActivation

+activationWithEnvironment:(KBEnvironment*)env implementation:(void*)impl
{
    return [[[self alloc]initWithEnvironment: env implementation: impl]autorelease];
}

-initWithEnvironment:(KBEnvironment*)env implementation:(void*)impl
{
    if(self = [super init])
    {
        _environment = env;
        _impl = (ACTIVATION*)impl;
    }
    return self;
}

-(KBEnvironment*)environment
{
    return _environment;
}

-(KBRule*)rule
{
    NSArray* rules = [_environment rules];
    int i, count = [rules count];
    for(i = 0; i < count; ++i)
    {
        KBRule* rule = [rules objectAtIndex: i];
        if([rule _impl] == _impl->theRule)
        {
            return rule;
        }
    }
    return [KBRule ruleWithEnvironment:_environment implementation: _impl->theRule]; // no object for the rule - make one
}

-(int)salience
{
    return _impl->salience;
}

-(NSString*)description
{
    NSString* tmp = [NSString stringWithFormat:@"%-6d ",[self salience]];
    return [tmp stringByAppendingString: [[self rule] name]];    
}

-(NSString*)basisDescription
{
    void* theEnv = [[self environment] _impl];
    ACTIVATION* theActivation = _impl;
    
    KBRouter* router = [[self environment] routerForName: @"scratch"];
    [router activate];
    [router setDelegate: [NSMutableString string]];
    
    struct partialMatch *list = theActivation->basis;
    struct patternEntity *matchingItem;
    short int i;

    for (i = 0; i < (int) list->bcount;)
    {
        if ((matchingItem = get_nth_pm_match(list,i)->matchingItem) != NULL)
        {
            PrintFactWithIdentifier(theEnv,(char*)[[router name] UTF8String],(struct fact*)matchingItem);
        }
        i++;
        if (i < (int) list->bcount) [router appendString: @"\n"];
    }

    [router deactivate];
    return (NSString*)[router delegate];
}

-(void*)_impl
{
    return _impl;
}

@end
