//
//  KBRule.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sun Sep 29 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import "KBRule.h"
#import "KBRouter.h"
#import <CLIPS/clips.h>
#import <Cocoa/Cocoa.h>

static clipsParseConstructFunction parse; 
static clipsUndefConstructFunction destroy;

static int KBParseConstructFunction(void *envImpl,char *logicalName)
{
    int result = parse(envImpl,logicalName);
    if(result == 0)
    {
        KBEnvironment* env = [KBEnvironment environmentForImplementation:envImpl];
        [env syncRules];
        [env syncActivations];
    }
    return result;
}

static int KBUndefConstructFunction(void *envImpl,void* impl)
{
    int success = destroy(envImpl,impl);
    if(success)
    {
        KBEnvironment* env = [KBEnvironment environmentForImplementation:envImpl];
        [env _removeRuleForImpl: impl];
        [env syncActivations];
    }
    return success;
}

@implementation KBRule

+(void)hookConstructInEnvironment:(KBEnvironment*) env
{
    struct construct* dt = DefruleData([env _impl])->DefruleConstruct;

    // make sure we don't hook twice.
    if(KBUndefConstructFunction == dt->deleteFunction) return;
    
    parse = dt->parseFunction;
    dt->parseFunction = KBParseConstructFunction;
    
    destroy = dt->deleteFunction;
    dt->deleteFunction = KBUndefConstructFunction;
}

+(void)unhookConstructInEnvironment:(KBEnvironment*) env
{
    struct construct* dt = DefruleData([env _impl])->DefruleConstruct;

    // make sure we don't unhook twice.
    if(KBUndefConstructFunction != dt->deleteFunction) return;
    
    dt->parseFunction = parse;
    parse = 0;
    
    dt->deleteFunction = destroy;
    destroy = 0;
}

+ruleWithEnvironment:(KBEnvironment*) env name:(NSString*) name
{
    return [[[self alloc]initWithEnvironment:env name:name] autorelease];
}

+ruleWithEnvironment:(KBEnvironment*) env implementation:(void*) impl
{
    return [[[self alloc]initWithEnvironment:env implementation:impl] autorelease];
}

-initWithEnvironment:(KBEnvironment*) env name:(NSString*) name
{
    return [self initWithEnvironment: env implementation: EnvFindDefrule([env _impl],(char*)[name UTF8String])];
}

-initWithEnvironment:(KBEnvironment*) env implementation:(void*) impl
{
    if(self = [super initWithName: [NSString stringWithUTF8String:EnvGetConstructNameString([env _impl],(struct constructHeader*)impl)]])
    {
        _environment = env;
        _impl = impl;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(KBEnvironment*)environment
{
    return _environment;
}

-(BOOL)breakpoint
{
    return EnvDefruleHasBreakpoint([_environment _impl],_impl);
}

-(void)setBreakpoint:(BOOL)b
{
    if(b) EnvSetBreak([_environment _impl],_impl);
    else EnvRemoveBreak([_environment _impl],_impl);
}

-(BOOL)watchActivation
{
    return (BOOL)EnvGetDefruleWatchActivations([_environment _impl],_impl);
}

-(void)setWatchActivation:(BOOL)b
{
    EnvSetDefruleWatchActivations([_environment _impl],(b != 0),_impl);
}

-(BOOL)watchFiring
{
    return (BOOL)EnvGetDefruleWatchFirings([_environment _impl],_impl);
}

-(void)setWatchFiring:(BOOL)b
{
    EnvSetDefruleWatchFirings([_environment _impl],(b != 0),_impl);
}

-(NSString*)matchSummary
{
    KBRouter* router = [[self environment] routerForName: @"wdisplay"];
    [router activate];
//    [router setDelegate: [NSMutableString new]];
    [router setDelegate:[[NSMutableString alloc] init]];
    EnvMatches([[self environment] _impl],_impl);
    [router deactivate];
    return (NSString*)[[router delegate]autorelease];
}


-(NSString*)description
{
/*
    KBRouter* router = [[self environment] routerForName: @"scratch"];
    [router activate];
    [router setDelegate: [NSMutableString string]];
    PPDefrule([[self environment] _impl],(char*)[[self name] UTF8String],(char*)[[router name] UTF8String]);
    [router deactivate];
    return (NSString*)[router delegate];
*/
    NSString *str = [NSString stringWithUTF8String:
                     (DefruleData([[self environment]_impl])->DefruleConstruct)->
                getPPFormFunction([[self environment]_impl],(struct constructHeader *)[self _impl])];
    return str;
}

-(void*)_impl
{
    return _impl;
}

@end
