//
//  KBTemplate.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/clips.h>

#import "KBTemplate.h"
#import "KBEnvironment.h"
#import "KBRouter.h"
#import "KBTemplateSlot.h"
#import "KBModule.h"
#import "KBFact.h"
#import <CoreData/CoreData.h>

static clipsParseConstructFunction parse; 
static clipsUndefConstructFunction destroy;

static int KBParseConstructFunction(void *envImpl,char *logicalName)
{
    int result = parse(envImpl,logicalName);
    if(result == 0)
    {
        KBEnvironment* env = [KBEnvironment environmentForImplementation:envImpl];
        [env syncTemplates];
    }
    return result;
}

static int KBUndefConstructFunction(void *envImpl,void* impl)
{
    int result = destroy(envImpl,impl);
    KBEnvironment* env = [KBEnvironment environmentForImplementation:envImpl];
    [env _removeTemplateForImpl: impl];
    return result;
}

@implementation KBTemplate

+(void)hookConstructInEnvironment:(KBEnvironment*) env
{
    struct construct* dt = DeftemplateData([env _impl])->DeftemplateConstruct;

    // make sure we don't hook twice.
    if(KBUndefConstructFunction == dt->deleteFunction) return;
    
    parse = dt->parseFunction;
    dt->parseFunction = KBParseConstructFunction;
    
    destroy = dt->deleteFunction;
    dt->deleteFunction = KBUndefConstructFunction;
}

+(void)unhookConstructInEnvironment:(KBEnvironment*) env
{
    struct construct* dt = DeftemplateData([env _impl])->DeftemplateConstruct;

    // make sure we don't unhook twice.
    if(KBUndefConstructFunction != dt->deleteFunction) return;
    
    dt->parseFunction = parse;
    parse = 0;
    
    dt->deleteFunction = destroy;
    destroy = 0;
}




+templateWithEnvironment:(KBEnvironment*) env implementation:(void*) impl
{
	if([env extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    return [[[self alloc]initWithEnvironment: env implementation: impl] autorelease];
}

-initWithEnvironment:(KBEnvironment*) env implementation:(void*) impl
{
	if([env extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if(self = [super init])
    {
        if(impl == nil)
        {
            [self autorelease];
            [NSException raise: @"KBInvalidTemplateException"
                        format: @"deftemplate is nil"];
        }
        _environment = env;
        _impl = impl;
        _facts = [NSMutableArray new];
        if(ValueToString(((struct deftemplate*)impl)->header.name))
        {
            [self setName:[NSString stringWithUTF8String: ValueToString(((struct deftemplate*)impl)->header.name)]];
        }
        else
        {
            [self setName:[NSString stringWithFormat: @"(Unstructured %x)",impl]];
        }
    }
    return self;
}

-(void) dealloc
{
    [_slots release];
    [_facts release];
    [super dealloc];    
}

-(NSString*)factsListing
{
    NSMutableArray* array = [[self facts] mutableCopy];
    int i, count = [array count];
    for(i = 0; i < count; ++i)
    {
        [array replaceObjectAtIndex:i 
                         withObject:[[array objectAtIndex: i] descriptionWithIdentifier]];
    }
    NSString* val = [array componentsJoinedByString:@"\n\n"];
    [array release];
    return val;
}

-(id)entityDescription
{
    return _entityDescription;
}

-(void)setEntityDescription:(id)desc
{
    _entityDescription = desc;
}

-(void)copyValuesFromObject:(id)object toFact:(KBFact*)fact
{
    if([self isImplied] || [fact index] != 0 || [fact isGarbage]) return;
    // we can't copy values to this - either its already asserted or
    // its not a structured fact

    NSArray* slots = [self slots];
    int i, count = [slots count];

    for(i = 0; i < count; ++i)
    {
        [[slots objectAtIndex: i] copyFromObject: object toFact: fact];
    }
}


-(NSArray*)slots
{
    if(!_slots)
    {
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: 20];
        struct templateSlot *slotPtr = _impl->slotList;
        while (slotPtr)
        {
            KBTemplateSlot* slot = [KBTemplateSlot slotWithTemplate: self implementation: slotPtr]; 
            [array addObject: slot];
            [slot setPropertyDescription: [[_entityDescription propertiesByName] objectForKey: [slot name]]];
            slotPtr = slotPtr->next;
        }
        _slots = [[NSArray arrayWithArray: array] retain];
    }
    return _slots;
}

-(NSArray*)keyPaths
{
    return [[self slots] valueForKeyPath: @"name"];    
}


-(BOOL)isImplied
{
    return _impl->implied;
}

-(KBEnvironment*)environment
{
    return _environment;
}
#if DEFMODULE_CONSTRUCT

-(KBModule*)module
{
    if(!_module)
    {
        NSString* module = [NSString stringWithUTF8String: EnvDeftemplateModule([_environment _impl],_impl)];
        _module = [[self environment] moduleForName: module];
    }
    return _module;
}
#endif

-(NSMutableArray*)facts
{
    return _facts;
}

/*
SYNC_KEY(facts,EnvGetNextFact,KBFact factWithTemplate:)

-(void)syncTemplates
{
    [self _sync_templates];
}
*/

-(void)syncFacts
{
	if([[self environment] extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    BOOL changed = NO;
    struct fact* ptr = FactData([[self environment]_impl])->FactList;
    int i = 0, count = [_facts count];
    
    while(ptr)
    {
        if(ptr->whichDeftemplate == _impl)
        {
            if(i < count)
            {
                if([[_facts objectAtIndex: i] _impl] != ptr)
                {
                    int j;
                    for(j = i+1; j < count; ++j)
                    {
                        if([[_facts objectAtIndex: j] _impl] == ptr)
                        {
                            while([[_facts objectAtIndex: i] _impl] != ptr)
                            {
                                if(!changed) 
                                {
                                    [self willChangeValueForKey: @"facts"];
                                    changed = YES;
                                }
                                [_facts removeObjectAtIndex: i];
                                --count;
                            }
                        }
                    }
                    if([[_facts objectAtIndex: i] _impl] != ptr)
                    {
                        if(!changed) 
                        {
                            [self willChangeValueForKey: @"facts"];
                            changed = YES;
                        }
                        [_facts insertObject: [KBFact factWithTemplate:self implementation: ptr] atIndex: i];
                        ++count;
                    }
                }
                ++i;
            }
            else
            {
                if(!changed) 
                {
                    [self willChangeValueForKey: @"facts"];
                    changed = YES;
                }
                [_facts addObject: [KBFact factWithTemplate:self implementation: ptr]];
            }
        }
        ptr = ptr->nextFact;
    }
    while(i < count)
    {
        if(!changed) 
        {
            [self willChangeValueForKey: @"facts"];
            changed = YES;
        }
        [_facts removeObjectAtIndex: i];
        --count;
    }
    
    if(changed)
    {
        [self didChangeValueForKey: @"facts"];
    }
}

-(NSString *) description
{
    char* str = (DeftemplateData([[self environment]_impl])->DeftemplateConstruct)->
                    getPPFormFunction([[self environment]_impl],(struct constructHeader *)[self _impl]);
    if(!str)
    {
        return [self name];
    }
    return [NSString stringWithUTF8String: str];
}

// registers self for observing, but forwards all notifications to environment
// one day we may have custom templates
-(void)observeObject:(id)object
{
	if([[self environment] extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    NSArray* slots = [self slots];
    int i, count = [slots count];
    for(i = 0; i < count; ++i)
    {
        KBTemplateSlot* slot = [slots objectAtIndex: i];
        if([[slot name] isEqualToString: @"self"]) continue;
        [object addObserver:self
                forKeyPath:[slot name] 
                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                context:nil];
    }
}

-(void)ignoreObject:(id)object
{
	if([[self environment] extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    NSArray* slots = [self slots];
    int i, count = [slots count];
    for(i = 0; i < count; ++i)
    {
        KBTemplateSlot* slot = [slots objectAtIndex: i];
        if([[slot name] isEqualToString: @"self"]) continue;
        [object removeObserver:self forKeyPath:[slot name]]; 
    }
}

// forward notification to environment
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
// env will log
//	if([[self environment] extraLogging])NSLog(@"%@ %@ entry, KeyPath = %@",[self className],NSStringFromSelector( _cmd ), keyPath);
    [[self environment] observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void*)_impl 
{ 
    return _impl; 
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey 
{
    BOOL automatic;
    if ([theKey isEqualToString:@"facts"] || [theKey isEqualToString:@"factsListing"]) 
    {
        automatic=NO;
    } 
    else 
    {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

+ (void)initialize {
    [self setKeys:[NSArray arrayWithObjects:@"facts",nil]
    triggerChangeNotificationsForDependentKey:@"factsListing"];
}

@end

@implementation NSObject (KBCLIPSTemplateName)

-(NSString*)clipsTemplateName
{
    return [self className];
}

@end
