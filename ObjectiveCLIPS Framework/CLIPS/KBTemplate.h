//
//  KBTemplate.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveCLIPS/KBConstruct.h>
#import <CLIPS/setup.h>

struct deftemplate;
@class KBEnvironment;
@class KBModule;
@class KBFact;

@interface KBTemplate : KBConstruct 
{
    KBEnvironment*		_environment;
#if DEFMODULE_CONSTRUCT
    KBModule*           _module;
#endif
    id                  _entityDescription;
    NSArray*            _slots;
    NSMutableArray*     _facts;
    struct deftemplate*	_impl;
}

+templateWithEnvironment:(KBEnvironment*) env implementation:(void*) impl;
-initWithEnvironment:(KBEnvironment*) env implementation:(void*) impl;

-(void)copyValuesFromObject:(id)object toFact:(KBFact*)fact;

-(BOOL)isImplied;
-(NSArray*)slots;

-(KBEnvironment*)environment;
#if DEFMODULE_CONSTRUCT
-(KBModule*)module;
#endif
-(NSMutableArray*)facts;
-(void)syncFacts;

-(id)entityDescription;
-(void)setEntityDescription:(id)desc;

-(void)observeObject:(id)object;
-(void)ignoreObject:(id)object;

-(void*)_impl;

@end

@interface NSObject (KBCLIPSTemplateName)

-(NSString*)clipsTemplateName;

@end