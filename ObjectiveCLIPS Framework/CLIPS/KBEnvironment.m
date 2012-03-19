//
//  KBEnvironment.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Fri Sep 20 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//
#import <CLIPS/clips.h>

#import <Foundation/NSThread.h>

#import <FScript/FScript.h>
#import "KBEnvironment.h"
#import "KBObjectModel.h"
#import "KBTemplate.h"
#import "KBFact.h"
#import "KBDataObject.h"
#import "KBRouter.h"
#import "KBRule.h"
#import "KBActivation.h"
#import "KBModule.h"
#import "KBPointerKeyDictionary.h"
#import "FSInterpreter_CLIPSAdditions.h"

static KBPointerKeyDictionary* _implToKBEnvironment;

static void KBEnvironmentPeriodicFunction(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentPeriodicFunction");
    [env doPeriodicTasks];
}

static int KBEnvironmentShouldReset(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentShouldReset");
    return [env environmentShouldReset: env];
}

static void KBEnvironmentWillReset(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentWillReset");
    [env environmentWillReset: env];
}

static void KBEnvironmentDidReset(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentDidReset");
    [env environmentDidReset: env];
}

static int KBEnvironmentShouldClear(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentShouldClear");
    return [env environmentShouldClear: env];
}

static void KBEnvironmentWillClear(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentWillClear");
    [env environmentWillClear: env];
}

static void KBEnvironmentDidClear(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentDidClear");
    [env environmentDidClear: env];
}

static void KBEnvironmentWillRun(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
//    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentWillRun");
    [env environmentWillRun: env];
}

static void KBEnvironmentDidRun(void* impl)
{
    KBEnvironment* env = [KBEnvironment environmentForImplementation:impl];
//    if([env extraLogging])NSLog(@"static KBEnvironment KBEnvironmentDidRun");
    [env environmentDidRun: env];
}

static int comparePriorities(id r1, id r2, void *ctx)
{
    KBRouter* left = (KBRouter*) r1;
    KBRouter* right = (KBRouter*) r2;
    return [right priority] - [left priority];
}


@implementation KBEnvironment

-(BOOL) extraLogging 
{
       return _extraLogging;
}

-(void) setExtraLogging:(BOOL)val 
{
       _extraLogging = val;
}

-(NSString*)version
{
    // note that version 1.0 lacked this method
    static NSString* version = nil;
    if(!version)
    {
        NSBundle* bundle = [NSBundle bundleForClass: [self class]];
        version = [[bundle objectForInfoDictionaryKey: @"CFBundleShortVersionString"] retain];
    }
    return version;
}

+(KBEnvironment*)environmentForImplementation:(void*)impl
{
//	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    return [_implToKBEnvironment objectForKey:impl];
}

+(void)setEnvironment:(KBEnvironment*) env forImplementation:(void*)impl
{
	if([env extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if(!_implToKBEnvironment)
    {
        _implToKBEnvironment = [[KBPointerKeyDictionary dictionaryWithCapacity:19 weakReferences:YES] retain];
    }
    [_implToKBEnvironment setObject: env forKey: impl];
}

+(void)removeEnvironmentForImplementation:(void*)impl
{
    KBEnvironment* env = [self environmentForImplementation: impl];
	if([env extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    [_implToKBEnvironment removeObjectForKey: impl];
}

-(void)setAutoRun:(BOOL)b
{
    if(!b)
    {
		if(_extraLogging)NSLog(@"%@ %@ entry, OFF",[self className],NSStringFromSelector( _cmd ));
        [_runTimer invalidate];
        _runTimer = nil;
        _autoRun = b;
    } else
		if(_extraLogging)NSLog(@"%@ %@ entry, ON",[self className],NSStringFromSelector( _cmd ));
		
    if(!_autoRun && b)
    {
        _autoRun = b;
        [self runAtNextOpportunity];
    }
}

-(BOOL)autoRun
{
    return _autoRun;
}

-(void)setRunLimit:(long)i
{
    _runLimit = i;
}

-(long)runLimit
{
    return _runLimit;
}

-(void)runAtNextOpportunity
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if(_runTimer != nil)
    {
		if(_extraLogging)NSLog(@"%@ %@ ignored, already set to run",[self className],NSStringFromSelector( _cmd ));
        return;
    }
    
    if(!_autoRun) 
    {
		if(_extraLogging)NSLog(@"%@ %@ not autorun, just sync activations and exit",[self className],NSStringFromSelector( _cmd ));
        [self syncActivations];
        return;
    }
    
    _runTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(run) userInfo:nil repeats:NO];
	if(_extraLogging)NSLog(@"%@ %@ exit, timer set",[self className],NSStringFromSelector( _cmd ));
}

-(long)run
{
	if(_extraLogging)NSLog(@"%@ %@ entry, thread = %@, multi = %@",[self className],NSStringFromSelector( _cmd ), [NSThread currentThread], ([NSThread isMultiThreaded]?@"YES":@"NO"));

    if([self isRunning]) return 0; // If CLIPS is running
    
	BOOL canBeCleanRun = _noFactsModified; //_updateFactsForModifiedObjects
	_cleanRun = NO;

    long times = [self runWithLimit: _runLimit];
        
	_cleanRun = ( canBeCleanRun && _noFactsModified );
    	
	if( _runTimer == nil ) [self environmentDidRun:self]; // kick the endUndo, if not set to re-run

	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
	return times;
}

-(long)runWithLimit:(long)limit
{
	if(_extraLogging)NSLog(@"%@ %@ entry, limit = %ld",[self className],NSStringFromSelector( _cmd ),limit);
    [_runTimer invalidate];
    _runTimer = nil;

    long times = 0;

    if([self isRunning]) // If CLIPS is running
    {
		if(_extraLogging)NSLog(@"%@ %@ CLIPS already running",[self className],NSStringFromSelector( _cmd ));
        return times;
    }

    @try
    {
        [self lock];
		if(_extraLogging)NSLog(@"%@ %@ running CLIPS",[self className],NSStringFromSelector( _cmd ));
        times = EnvRun(_impl,limit); // run CLIPS
    }
    @finally
    {
        [self unlock];
		if(_extraLogging)NSLog(@"%@ %@ update facts",[self className],NSStringFromSelector( _cmd ));
        [self _updateFactsForModifiedObjects];
        if([self haltExecution])
        {
            [self setHaltExecution: NO];
        }      
        if(times > 0) 
        {
            EnvSetAgendaChanged(_impl,YES);
			if(_extraLogging)NSLog(@"%@ %@ agenda changed -> sync activations",[self className],NSStringFromSelector( _cmd ));
            [self syncActivations];
        }
    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
    return times;
}

-(BOOL)haltExecution
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    BOOL val =  GetHaltExecution(_impl);
	if(_extraLogging)NSLog(@"%@ %@ exit, %s",[self className],NSStringFromSelector( _cmd ), (val?"YES":"NO"));
	return val;
}

-(void)setHaltExecution:(BOOL)yorn
{
	if(_extraLogging)NSLog(@"%@ %@ entry, %s",[self className],NSStringFromSelector( _cmd ), (yorn?"YES":"NO"));
    SetHaltExecution(_impl,yorn);
}

-(BOOL)isRunning
{
    return EngineData(_impl)->AlreadyRunning;
}

-(void)reset
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    EnvReset(_impl);
}

-(void)clear
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    EnvClear(_impl);
}

-(int)loadFile:(NSString*)filename
{
    [self lock];
    int result = EnvLoad(_impl,(char*)[filename UTF8String]);
    [self unlock];
    [self doPeriodicTasks];
    return -1 == result;
}

-(void)doPeriodicTasks
{
	if(_extraLogging)NSLog(@"%@ %@ empty",[self className],NSStringFromSelector( _cmd ));
    //[self environmentCleanup];
    //[self environmentDidChange: self];
}

-(unsigned long)nextFactIndex
{
    return FactData(_impl)->NextFactIndex;
}

-(unsigned long)previousNextFactIndex
{
    return _previousNextFactIndex;
}

-(void)updateFactIndex
{
    _previousNextFactIndex = [self nextFactIndex];
}

-(BOOL)performCommand:(NSString*)command
{
    return [self performCommand: command printResult: NO];
}

-(BOOL)performCommand:(NSString*)command printResult:(BOOL) yorn
{
	if(_extraLogging)NSLog(@"%@ %@ entry, command = %@",[self className],NSStringFromSelector( _cmd ), command);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL result = RouteCommand(_impl,(char*)[command UTF8String],yorn);

    [self setHaltExecution: NO];
    [pool release];
    return result;
}

-(BOOL)couldPerformCommand:(NSString*)cmd
{
    // CompleteCommand only works if the string ends with a return
    return CompleteCommand((char*)[[cmd stringByAppendingString: @"\n"]UTF8String]);
}

-init
{
    if(self = [super init])
    {
        _autoRun = YES;
        _runLimit = 30;
        _impl = CreateEnvironment();
        /* map the pointer to the object so we can find it from the callbacks */
        [KBEnvironment setEnvironment:self forImplementation: _impl];

        /* These replace the calls for parseConstruct and destroyConstruct */
        /* in their respective constructs.  They do much better */
        [KBTemplate hookConstructInEnvironment: self];
    

        /* oddly there's only one of these per environment */
        SetBeforeResetFunction(_impl,KBEnvironmentShouldReset);
        EnvAddResetFunction(_impl, "KBEnvironment", KBEnvironmentWillReset, 1000);
        EnvAddResetFunction(_impl, "KBEnvironment", KBEnvironmentDidReset, -1000);
        
        /* but several of these - we get in last because otherwise don't bother us */
        AddClearReadyFunction(_impl, "KBEnvironment", KBEnvironmentShouldClear, -1000);
        EnvAddClearFunction(_impl, "KBEnvironment", KBEnvironmentWillClear, 1000);
        EnvAddClearFunction(_impl, "KBEnvironment", KBEnvironmentDidClear, -1000);

        /* before and after run - there's no hook for declining to run */
        EnvAddRunFunction(_impl, "KBEnvironment", KBEnvironmentWillRun, 1000);
        EnvAddRunFunction(_impl, "KBEnvironment", KBEnvironmentDidRun,-1000);

        /* various name lookup dictionaries */
        _factsByObject = [KBPointerKeyDictionary new];
        _templatesByImpl = [KBPointerKeyDictionary new];
        _rulesByImpl = [KBPointerKeyDictionary new];
        _activationsByImpl = [KBPointerKeyDictionary new];
        
        /* ordered collections of these objects (mostly for UI binding) */
        _templates = [NSMutableArray new];
        _rules = [NSMutableArray new];
        _activations = [NSMutableArray new];
        _routers = [NSMutableDictionary new];

#if DEFMODULE_CONSTRUCT
        _modules = [NSMutableDictionary new];
#endif
        _modified = [NSMutableSet new];
        
        /* routers sorted by priority - higher numbers first */
        _sortedRouters = [NSMutableArray new];
        _fscriptBlockCache = [NSMutableDictionary new];
        _interpreter = [FSInterpreter new];
        [_interpreter _attachToEnvironment: self];

        /* the KBObjectModel will introspect vanilla Objective-C objects */
        /* most apps will want to replace it with the KBManagedObjectContect as the delegate */
        [self setTemplateDelegate:[KBObjectModel new]];
    }
    /* the templateDelegate only gets called when a deftemplate is missing - so define it first */
    [self performCommand:@"(deftemplate KBEnvironment (field self))"];
    [self assertObject: self];
    
    /* wire the environment for sound */
    EnvAddPeriodicFunction(_impl,"KBEnvironment",KBEnvironmentPeriodicFunction,1000);
    
    return self;
}

-(FSInterpreter*)interpreter
{
    return _interpreter;
}

-(void)loadDeveloperTools
{
    [self setExtraLogging:YES];
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if(!_devToolsLoaded)
    {
        _devToolsLoaded = YES;
        [NSBundle loadNibNamed: @"CLIPS" owner: self];
        // turn on verbose logging
        [self performCommand: @"(watch all)"];
    }
}

-(void)installRouters
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    /* protect against multiple calls */
    if(![_routers objectForKey: @"scratch"])
    {
        NSArray* names = [NSArray arrayWithObjects: @"stdout",@"wdialog",@"wdisplay",@"werror",@"wwarning",@"wtrace",nil];
        /* set up a scratch router for printing constructs - used by description methods */
        /* scratch will claime to be any router and intercept any output if it is active */
        KBRouter* scratch = [[KBRouter alloc] initWithEnvironment: self name: @"scratch" priority: 2000];
        int i, count = [names count];
        for(i = 0; i < count; ++i)
        {
            [scratch addAlias: [names objectAtIndex: i]];
        }
    }
}

-(void)dealloc
{
    [_factsByObject release];
    [_templatesByImpl release];
    [_rulesByImpl release];
    [_activationsByImpl release];
    
    [_templates release];
    [_rules release];
    [_activations release];
#if DEFMODULE_CONSTRUCT
    [_modules release];
#endif
    [_modified release];
    [_sortedRouters release];
    [_interpreter release];
    [KBEnvironment removeEnvironmentForImplementation:_impl];
    
    if(!DestroyEnvironment(_impl))
    {
        NSLog(@"CLIPS: DestroyEnvironment failed!?!?");
    }
    
    [[_routers allValues] makeObjectsPerformSelector: @selector(release)];
    [_routers release];
    [_fscriptBlockCache release];
    [super dealloc];
}

// FScript expression cache
-(KBBlock*)_cachedBlockForData:(NSData*)data
{
    return [_fscriptBlockCache objectForKey: data];
}

-(void)_cacheBlock:(KBBlock*)blk forData:(NSData*)data
{
    [_fscriptBlockCache setObject: blk forKey: data];
}

-(NSMutableArray*)templates
{
    return _templates;
}

-(KBTemplate*)templateForName:(NSString*)name
{
	if(_extraLogging)NSLog(@"%@ %@ entry, name = %@",[self className],NSStringFromSelector( _cmd ), name);
    // not many templates, linear search is fine.
    void* t = EnvFindDeftemplate(_impl,(char*)[name UTF8String]);
    if(t)
    {
        int i, count = [_templates count];
        KBTemplate* template = nil;
        
        for(i = 0; i < count; ++i)
        {
            template = [_templates objectAtIndex: i];
            if([template _impl] == t)
            {
                return template;
            }
        }
        [self willChangeValueForKey: @"templates"];
        template = [KBTemplate templateWithEnvironment:self implementation: t];
        [[self templates] addObject: template];
        [self didChangeValueForKey: @"templates"];
        return template;
    }
    return [_templateDelegate templateForName: name inEnvironment: self];
}

-(KBTemplate*) templateForObject:(id)obj
{
    KBTemplate* t = nil;
    if([_templateDelegate respondsToSelector:@selector(templateForObject:inEnvironment:)])
    {
        t = [_templateDelegate templateForObject:obj inEnvironment: self];
    }
    else if([obj respondsToSelector: @selector(clipsTemplateName)])
    {
        t = [self templateForName:[obj clipsTemplateName]];
    }
    else
    {
        t = [self templateForName:[obj className]];
    }
    return t;
}

-(void)syncTemplates
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    // linear search of all templates - kind of a drag but template definition is rare (we hope).
    // and we compare by pointer alone.  No need to cull as the destroy hook will do that.
    // Also, this should only be called when a new rule is defined - not periodically as before.
    NSMutableArray* newTemplates = [NSMutableArray arrayWithCapacity: 4];
    void* ptr = 0;
    while((ptr = EnvGetNextDeftemplate(_impl,ptr)) != 0)
    {
        KBTemplate* template = [_templatesByImpl objectForKey: ptr];
        if(!template)
        {
            template = [KBTemplate templateWithEnvironment: self implementation: ptr];
            [self _setTemplate: template forImpl: ptr];
            [newTemplates addObject: template];
        }
    }
    if([newTemplates count])
    {
        [self willChangeValueForKey: @"templates"];
        [_templates addObjectsFromArray: newTemplates];
        [self didChangeValueForKey: @"templates"];
    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

-(void)assertObject:(id)object
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    KBFact* fact = [self factForObject: object];
    if(fact) return;
    
    KBTemplate* template = [self templateForObject: object];
    [template observeObject: object];
    
    fact = [KBFact factWithTemplate: template object: object];
    [_factsByObject setObject:fact forKey:object];
    [fact assert];
//    if(![self isRunning]) 
//    {
        [self runAtNextOpportunity];
//    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

-(void)retractObject:(id)object
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    KBFact* fact = [self factForObject: object];
    if(!fact) return;
    
    [[fact template] ignoreObject: object];
    [fact retract];

    // no point in doing any pending updates
    [_modified removeObject: object];
    [_factsByObject removeObjectForKey:object];
    

//    if(![self isRunning]) 
//    {
        [self runAtNextOpportunity];
//    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	if(_extraLogging)NSLog(@"%@ %@ entry, KeyPath = %@, on Object = %@, changes = %@",[self className],NSStringFromSelector( _cmd ), keyPath, [object className], change);
	if(_extraLogging)NSLog(@"%@ %@ entry, KeyPath = %@",[self className],NSStringFromSelector( _cmd ), keyPath);
    [_modified addObject: object];
    
//    if(![self isRunning])
//    {
		if(_extraLogging)NSLog(@"%@ %@ update facts",[self className],NSStringFromSelector( _cmd ));
        [self _updateFactsForModifiedObjects];
//    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

-(void)commandLoop
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    CommandLoop(_impl);
}

-(void) environmentCleanup
{
	if(_extraLogging)NSLog(@"%@ %@ entry, update facts",[self className],NSStringFromSelector( _cmd ));
    [self _updateFactsForModifiedObjects];
}

-(NSArray*)facts
{
   struct fact* aFact = FactData(_impl)->FactList;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: GetNumberOfFacts(_impl)];
    while(aFact)
    {
        [array addObject: [KBFact factWithEnvironment:self implementation:aFact]];
        aFact = aFact->nextFact;
    }
    return array;
}

-(KBFact*)factForObject:(id)object
{
    return (KBFact*) [_factsByObject objectForKey: object];
}

-(void*)_impl { return _impl; }

-(void)addRouter:(KBRouter*) r
{
    [_routers setObject: r forKey: [r name]];
    [_sortedRouters addObject: r];
    [_sortedRouters sortUsingFunction:comparePriorities context:nil];  
}

-(KBRouter*)routerForName:(NSString*)name
{
    KBRouter* router = [_routers objectForKey: name];
    if(!router && [name isEqualToString: @"scratch"])
    {
        [self installRouters];
        router = [_routers objectForKey: name];
    }
    return router;
}

-(KBRouter*)activeRouterForName:(NSString*) nm
{
    int i;
    for(i = 0; i < [_sortedRouters count]; ++i)
    {
        KBRouter* r = (KBRouter*) [_sortedRouters objectAtIndex: i];
        if([r active] && [r answersToName:nm]) 
        {
            return r;
        }
    }
    return nil;
}

-(void)lock { ++_lock; }
-(void)unlock { --_lock; }
-(BOOL)locked { return _lock != 0; }

+(KBEnvironment*) _environmentForImpl:(void*)impl
{
    return (KBEnvironment*) [_implToKBEnvironment objectForKey: impl];
}

-(void)syncRules
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if(!_trackRules) return;
    // linear search of all rules - kind of a drag but rule definition is rare (we hope).
    // and we compare by pointer alone.  No need to cull as the destroy hook will do that.
    // Also, this should only be called when a new rule is defined - not periodically as before.
    NSMutableArray* newRules = [NSMutableArray arrayWithCapacity: 4];
    void* ptr = 0;
    while((ptr = EnvGetNextDefrule(_impl,ptr)) != 0)
    {
        KBRule* rule = [_rulesByImpl objectForKey: ptr];
        if(!rule)
        {
            rule = [KBRule ruleWithEnvironment: self implementation: ptr];
            [self _setRule: rule forImpl: ptr];
            [newRules addObject: rule];
        }
    }
    if([newRules count])
    {
        [self willChangeValueForKey: @"rules"];
        [_rules addObjectsFromArray: newRules];
        [self didChangeValueForKey: @"rules"];
    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

-(NSArray*)rules
{
    if(!_trackRules)
    {
        _trackRules = YES;
        [KBRule hookConstructInEnvironment: self];
        [self syncRules];
    }
    return _rules;
}

-(void)syncActivations
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    // only refresh if anyone has ever asked for activations before and the agenda has actually changed
    if(_trackActivations && EnvGetAgendaChanged(_impl) && ![self isRunning])
    {
        [self willChangeValueForKey: @"activations"];
        
        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity: GetNumberOfActivations(_impl)];
        void* ptr = 0;
                
        while((ptr = EnvGetNextActivation(_impl,ptr)) != 0)
        {
            [array addObject: [KBActivation activationWithEnvironment: self implementation: ptr]];
        }
        [_activations autorelease];
        _activations = array;
        EnvSetAgendaChanged(_impl,NO);
        [self didChangeValueForKey: @"activations"];
    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
} 

-(NSArray*)activations
{
    /* don't ask - don't track */
    /* IOW, if you never ask for activations I don't bother to keep them in sync or issue notifications */
    /* this helps with making runtimes where we are embedded and invisible more efficient */
    if(!_trackActivations)
    {
        _trackActivations = YES;
		if(_extraLogging)NSLog(@"%@ %@ sync activations",[self className],NSStringFromSelector( _cmd ));
        [self syncActivations];
    }
    return _activations;
}

#if DEFMODULE_CONSTRUCT

-(NSArray*)modules
{
    NSMutableArray* array = [NSMutableArray array];
    void *module = EnvGetNextDefmodule(_impl,0);
    while(module)
    {
        KBModule* aModule = [KBModule moduleWithEnvironment: self implementation: module];
        if(![_modules objectForKey: [aModule name]])
        {
            [_modules setObject: aModule forKey: [aModule name]];
        }
        [array addObject: [_modules objectForKey: [aModule name]]];
        module = EnvGetNextDefmodule(_impl,module);
    }
    return array;
}

-(KBModule*)moduleForName:(NSString*)name
{
    KBModule* m = [_modules objectForKey: name];
    if(!m) [self modules]; // updates the dictionary
    return [_modules objectForKey: name];
}

#endif

static int depth = 0;

-(int)_updateFactsForModifiedObjects
{
	if(_extraLogging)NSLog(@"%@ %@ entry, depth = %d",[self className],NSStringFromSelector( _cmd ), depth);
	depth++;
    int factsChanged = 0;
    while([_modified count])
    {
        id object = [_modified anyObject];
		if(_extraLogging)NSLog(@"%@ %@ modified object = %@",[self className],NSStringFromSelector( _cmd ), [object className]);
        [_modified removeObject: object];
        factsChanged++; // sync trigger
		if( [[[object managedObjectContext] undoManager] isUndoing] )
			continue;
        KBFact* fact = [self factForObject: object];
        [fact modify];
    }
    if(factsChanged) {
		if(_extraLogging)NSLog(@"%@ %@ sync activations and run at next opportunity",[self className],NSStringFromSelector( _cmd ));
		[self syncActivations];
        [self runAtNextOpportunity];
		_noFactsModified = NO;
	} else
		_noFactsModified = YES;
		
	depth--;
	if(_extraLogging)NSLog(@"%@ %@ exit, facts changed = %d, depth = %d",[self className],NSStringFromSelector( _cmd ), factsChanged, depth);
    return factsChanged;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey 
{
    BOOL automatic;
    NSArray* keys = [NSArray arrayWithObjects:@"templates",@"rules",@"activations",nil]; 
    if ([keys containsObject: theKey]) 
    {
        automatic=NO;
    } 
    else 
    {
        automatic=[super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

-(void)_removeTemplateForImpl:(void*)impl
{
    [_templatesByImpl removeObjectForKey: impl];
}

-(void)_setTemplate:(KBTemplate*)t forImpl:(void*)impl
{
    [_templatesByImpl setObject:t forKey:impl];
}

-(KBTemplate*)_templateForImpl:(void*)impl
{
    KBTemplate* t = [_templatesByImpl objectForKey: impl];
    if(!t)
    {
        [self _setTemplate: (t = [KBTemplate templateWithEnvironment:self implementation:impl]) forImpl: impl];
    }
    return t;
}

-(void)_removeRuleForImpl:(void*)impl
{
    KBRule* t = [_rulesByImpl objectForKey: impl];
    if(t) 
    {
        [_rules removeObject: t];
        [_rulesByImpl removeObjectForKey: impl];
    }
}

-(void)_setRule:(KBRule*)t forImpl:(void*)impl
{
    [_rulesByImpl setObject:t forKey:impl];
}

-(KBRule*)_ruleForImpl:(void*)impl
{
    return [_rulesByImpl objectForKey: impl];
}


@end

@implementation KBEnvironment (KBTemplateDelegation)

-(void)setTemplateDelegate:(id)delegate
{
    _templateDelegate = delegate;
}

-(id)templateDelegate
{
    return _templateDelegate;
}

@end

@implementation KBEnvironment (KBEnvironmentRunDelegate)

-(void)setRunDelegate:(id)delegate
{
    _runDelegate = delegate;
}

-(id)runDelegate
{
    return _runDelegate;
}

-(void) environmentWillRun: (KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(enviromnentWillRun:)])
    {
        [_runDelegate environmentWillRun: self];
    }
	if(_extraLogging)NSLog(@"%@ %@ exit",[self className],NSStringFromSelector( _cmd ));
}

-(void) environmentDidRun:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry, running...",[self className],NSStringFromSelector( _cmd ));
//    int count = [self _updateFactsForModifiedObjects];

//	[self run];
    if([_runDelegate respondsToSelector: @selector(environmentDidRun:)])
    {
		if(_extraLogging)NSLog(@"%@ %@ calling ProjectDocument delegate ",[self className],NSStringFromSelector( _cmd ));
        [_runDelegate environmentDidRun: self];
    }
	if(_extraLogging)NSLog(@"%@ %@ exit ",[self className],NSStringFromSelector( _cmd ));
}

-(BOOL) environmentShouldClear:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(environmentShouldClear:)])
    {
        return [_runDelegate environmentShouldClear: self];
    }
    return YES;
}

-(void) environmentWillClear:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(environmentWillClear:)])
    {
        [_runDelegate environmentWillClear: self];
    }
}

-(void) environmentDidClear:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(environmentDidClear:)])
    {
        [_runDelegate environmentDidClear: self];
    }
    _previousNextFactIndex = 0;
    [_templates removeAllObjects];
#if DEFMODULE_CONSTRUCT
    [_modules removeAllObjects];
#endif
}

-(BOOL) environmentShouldReset:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(environmentShouldReset:)])
    {
        return [_runDelegate environmentShouldReset: self];
    }
    return YES;
}

-(void) environmentWillReset:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([_runDelegate respondsToSelector: @selector(environmentWillReset:)])
    {
        [_runDelegate environmentWillReset: self];
    }
}

-(void) environmentDidReset:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    _previousNextFactIndex = 0;
    
    if(nil == [self templateForObject: self])
    {
        [self performCommand:@"(deftemplate KBEnvironment (field self))"];
    }
    [self assertObject: self];

    if([_runDelegate respondsToSelector: @selector(environmentWillReset:)])
    {
        [_runDelegate environmentWillReset: self];
    }
}

-(void)environmentDidChange:(KBEnvironment*) env
{
	if(_extraLogging)NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
   if([_runDelegate respondsToSelector: @selector(environmentDidChange:)])
    {
        [_runDelegate environmentDidChange: self];
    }
}

@end


