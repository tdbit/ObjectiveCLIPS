//
//  KBRule.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sun Sep 29 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveCLIPS/KBEnvironment.h>
#import <ObjectiveCLIPS/KBConstruct.h>

@interface KBRule : KBConstruct 
{
    KBEnvironment *	_environment;
    struct defrule*	_impl;
}

+ruleWithEnvironment:(KBEnvironment*) env name:(NSString*) name;
+ruleWithEnvironment:(KBEnvironment*) env implementation:(void*) impl;

-initWithEnvironment:(KBEnvironment*) env name:(NSString*) name;
-initWithEnvironment:(KBEnvironment*) env implementation:(void*) impl;

-(BOOL)breakpoint;
-(void)setBreakpoint:(BOOL)b;

-(BOOL)watchActivation;
-(void)setWatchActivation:(BOOL)b;

-(BOOL)watchFiring;
-(void)setWatchFiring:(BOOL)b;

-(NSString*)matchSummary;

-(void*)_impl;

@end
