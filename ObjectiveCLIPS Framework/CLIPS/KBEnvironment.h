//
//  KBEnvironment.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Fri Sep 20 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/setup.h>

#import <Foundation/Foundation.h>
@class KBTemplate;
@class KBModel;
@class KBFact;
@class KBRule;
@class KBRouter;
@class FSInterpreter;
@class KBModule;
@class KBPointerKeyDictionary;
@class KBBlock;

@interface KBEnvironment : NSObject
{
    void*                   _impl;
    unsigned long           _previousNextFactIndex;
    
    KBPointerKeyDictionary* _factsByObject;
    KBPointerKeyDictionary* _templatesByImpl;
    KBPointerKeyDictionary* _rulesByImpl;
    KBPointerKeyDictionary* _activationsByImpl;
    
    NSMutableArray*         _templates;
    NSMutableArray*         _rules;
    NSMutableArray*         _activations;
    
    NSMutableDictionary*    _routers;
#if DEFMODULE_CONSTRUCT
    NSMutableDictionary*    _modules;
#endif
    NSMutableSet*           _modified;
    NSMutableArray*         _sortedRouters;
    NSMutableDictionary*    _fscriptBlockCache;
    int                     _lock;
    id                      _runDelegate;
    NSTimer*                _runTimer;
    FSInterpreter*          _interpreter;
    id                      _templateDelegate;
    BOOL                    _autoRun;
    BOOL                    _inPeriodicTask;
    long                    _runLimit;
    BOOL                    _devToolsLoaded;
    BOOL                    _trackActivations;
    BOOL                    _trackRules;
    BOOL                    _extraLogging;      // loadDeveloperTools sets flag to YES - LOTS of tracing

    // Runtime State Tracking
    BOOL                    _noFactsModified;   // no changes done
    BOOL                    _cleanRun;          // and a clean run, start to finish

}

-(BOOL) extraLogging;
-(void) setExtraLogging:(BOOL)val;

-(NSString*)version;
-(FSInterpreter*)interpreter;
-(void)loadDeveloperTools;

-(long)run;
-(long)runWithLimit:(long)limit;
-(void)runAtNextOpportunity;
-(BOOL)isRunning;

-(void)setAutoRun:(BOOL)b;
-(BOOL)autoRun;

-(void)setRunLimit:(long)i;
-(long)runLimit;

-(void)reset;
-(void)clear;

-(int)loadFile:(NSString*)filename; // returns zero on success, one otherwise

-(void)assertObject:(id)obj;
-(void)retractObject:(id)obj;

-(void)lock;
-(void)unlock;
-(BOOL)locked;

// access to the environment HaltExecution flag
-(BOOL)haltExecution;
-(void)setHaltExecution:(BOOL)yorn;

-(BOOL)couldPerformCommand:(NSString*)cmd;
-(BOOL)performCommand:(NSString*)command;
-(BOOL)performCommand:(NSString*)command printResult:(BOOL) yorn;

-(void)commandLoop;

-(void)environmentCleanup;
-(void)doPeriodicTasks;

// template finding
-(NSMutableArray*)templates;
-(KBTemplate*)templateForName:(NSString*)name;
-(KBTemplate*)templateForObject:(id)obj;
-(void)syncTemplates;

-(NSArray*)rules;
-(void)syncRules;

-(NSArray*)facts;
-(KBFact*)factForObject:(id)object;

-(NSArray*)activations;
-(void)syncActivations;

-(void)addRouter:(KBRouter*)router;
-(KBRouter*)routerForName:(NSString*)name;
-(KBRouter*)activeRouterForName:(NSString*) nm;

#if DEFMODULE_CONSTRUCT
-(KBModule*)moduleForName:(NSString*)name;
-(NSArray*)modules;
#endif
// the CLIPS environment pointer
-(void*)_impl;

// sync routine - updates facts for changed objects after each rule is run
-(int)_updateFactsForModifiedObjects;

-(void)_removeTemplateForImpl:(void*)impl;
-(void)_setTemplate:(KBTemplate*)t forImpl:(void*)impl;
-(KBTemplate*)_templateForImpl:(void*)impl;

-(void)_removeRuleForImpl:(void*)impl;
-(void)_setRule:(KBRule*)r forImpl:(void*)impl;
-(KBRule*)_ruleForImpl:(void*)impl;

// mapping between KBEnvironment and the CLIPS environment pointer
+(KBEnvironment*)environmentForImplementation:(void*)impl;
+(void)setEnvironment:(KBEnvironment*) env forImplementation:(void*)impl;
+(void)removeEnvironmentForImplementation:(void*)impl;

// FScript expression cache
-(KBBlock*)_cachedBlockForData:(NSData*)data;
-(void)_cacheBlock:(KBBlock*)blk forData:(NSData*)data;

@end

@interface KBEnvironment (KBEnvironmentRunDelegate)

-(void)setRunDelegate:(id)delegate;
-(id)runDelegate;

-(void) environmentWillRun:(KBEnvironment*) env;
-(void) environmentDidRun:(KBEnvironment*) env;

-(BOOL) environmentShouldClear:(KBEnvironment*) env;
-(void) environmentWillClear:(KBEnvironment*) env;
-(void) environmentDidClear:(KBEnvironment*) env;

-(BOOL) environmentShouldReset:(KBEnvironment*) env;
-(void) environmentWillReset:(KBEnvironment*) env;
-(void) environmentDidReset:(KBEnvironment*) env;

-(void) environmentDidChange:(KBEnvironment*) env;

@end

@interface KBEnvironment (KBTemplateDelegation)

-(void)setTemplateDelegate:(id)delegate;
-(id)templateDelegate;

@end


@interface NSObject (KBTemplateDelegate)

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env;
-(KBTemplate*) templateForObject:(id)obj inEnvironment:(KBEnvironment*) env;

@end
