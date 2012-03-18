//
//  KBModule.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 28 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/setup.h>

#import <Foundation/Foundation.h>
#import <ObjectiveCLIPS/KBNamedObject.h>

#if DEFMODULE_CONSTRUCT

@class KBEnvironment;
struct defmodule;


@interface KBModule : KBNamedObject 
{
    struct defmodule*	_impl;
    KBEnvironment*		_environment;
}

+moduleWithEnvironment:(KBEnvironment*) env implementation:(void*) impl;
-initWithEnvironment:(KBEnvironment*)env implementation:(void*)impl;

@end
#endif