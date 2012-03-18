//
//  KBModule.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 28 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import "KBModule.h"
#import "KBEnvironment.h"
#import "KBRouter.h"

#if DEFMODULE_CONSTRUCT

@implementation KBModule

+moduleWithEnvironment:(KBEnvironment*) env implementation:(void*) impl 
{ 
    return [[[self alloc] initWithEnvironment:env implementation:impl] autorelease]; 
}

-initWithEnvironment:(KBEnvironment*)env implementation:(void*)impl
{
    if(self = [super initWithName: [NSString stringWithUTF8String: EnvGetDefmoduleName([env _impl],impl)]])
    {
        _impl = impl;
        _environment = [env retain];
        
        if(!_impl)
        {
            // FIXME -- throw some exception
        }
    }
    return self;
}

-(void)dealloc
{
    [_environment release];
    [super dealloc];
}

-(KBEnvironment*)environment
{
    return _environment;
}

-(NSString*)description
{
    KBRouter* router = [[self environment] routerForName: @"scratch"];
    [router activate];
    [router setDelegate: [NSMutableString string]];
    PPDefmodule([[self environment] _impl],(char*)[[self name] UTF8String],(char*)[[router name] UTF8String]);
    [router deactivate];
    return (NSString*)[router delegate];
}


@end
#endif
