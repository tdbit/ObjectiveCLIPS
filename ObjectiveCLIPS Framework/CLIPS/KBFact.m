//
//  KBFact.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/clips.h>
#import "KBFact.h"
#import "KBEnvironment.h"
#import "KBTemplate.h"
#import "KBDataObject.h"
#import "KBRouter.h"


@implementation KBFact

+factWithTemplate:(KBTemplate*) tem object:(id) obj
{
    return [[[self alloc] initWithTemplate: tem object: obj] autorelease];
}

+factWithTemplate:(KBTemplate*) tem implementation:(struct fact*) impl
{
    return [[[self alloc] initWithTemplate: tem implementation: impl] autorelease];
}

+factWithEnvironment:(KBEnvironment*)env implementation:(struct fact*) impl
{
    KBTemplate* template = [env _templateForImpl: impl->whichDeftemplate];
    return [self factWithTemplate: template implementation: impl];
}

-initWithTemplate:(KBTemplate*) tem object:(id) obj;
{
    if(self = [super init])
    {
        _template = tem;
        if(_template)
        {
            _impl = EnvCreateFact([[_template environment] _impl],[_template _impl]);
            [tem copyValuesFromObject: obj toFact: self];
        }
        else
        {
            [self autorelease];
            return nil;
        }
    }
    return self;
}

-initWithTemplate:(KBTemplate*) tem implementation:(void*) impl;
{
    if(self = [super init])
    {
        _impl = impl;
        _template = tem;
    }
    return self;
}

-(void)dealloc
{
    [_cachedDescription release];
    [_cachedDescriptionWithIdentifier release];
    [super dealloc];
}

-(KBTemplate*)template
{
    return _template;
}

-(KBEnvironment*)environment
{
    return [_template environment];
}

-(unsigned long)index
{
    return _impl->factIndex;
}

-(id)object 
{ 
    DATA_OBJECT data = { 0 };
    if(EnvGetFactSlot([[_template environment] _impl],_impl,"self",&data))
    {
        return [NSObject objectForDataObject: &data inEnvironment: [[[self template] environment] _impl]];
    }
    return nil;
}

-(id)valueForKeyPath:(NSString*) nm
{
    DATA_OBJECT data = { 0 };
    if(EnvGetFactSlot([[_template environment] _impl],_impl,(char*)[nm UTF8String],&data))
    {
        return [NSObject objectForDataObject: &data inEnvironment: [[[self template] environment] _impl]];
    }
    else
    {
        return [super valueForKeyPath: nm]; 
    }
}

-(id)valueForKey:(NSString*)key
{
    return [[self object] valueForKey:key];
}

-(void)takeValue:(id) value forKey:(NSString*) nm
{
    [[self object]takeValue:value forKey:nm];
}

- (id)storedValueForKey:(NSString *)key;
{
    DATA_OBJECT data = { 0 };
    if(EnvGetFactSlot([[_template environment] _impl],_impl,(char*)[key UTF8String],&data))
    {
        return [NSObject objectForDataObject: &data inEnvironment: [[[self template] environment] _impl]];
    }
    else
    {
        return [super valueForKey: key]; 
    }
}

-(void)takeStoredValue:(id)value forKey:(NSString *)key;
{
    DATA_OBJECT data = { 0 };
    if(!value)
    {
        data.type = SYMBOL;
        data.value = EnvAddSymbol([[_template environment] _impl],"nil");
    }
    else
    {
        [value dataObject: &data inEnvironment: [_template environment]];
    }
    if(!EnvPutFactSlot([[_template environment] _impl],_impl,(char*)[key UTF8String],&data))
    {
        [super takeValue: value forKey: key];
    }
}

-(void)setDataObject:(DATA_OBJECT*)data forKey:(NSString*)key
{
    if(!EnvPutFactSlot([[_template environment] _impl],_impl,(char*)[key UTF8String],data))
    {
        [NSException raise: @"Invalid Fact Slot: " format:@"%@ does not exist.",key];
    }
}

-(id)valueForKeyPath:(NSString*)path inObject:(id)obj
{
    NSMutableArray* elements = [[path componentsSeparatedByString: @"."]mutableCopy];
    NSString* key = [elements lastObject];
    [elements removeLastObject];
    if([elements count])
    {
        obj = [obj valueForKeyPath: [elements componentsJoinedByString: @"."]];
    }
    SEL selector = NSSelectorFromString(key);
    NSMethodSignature* sig = [obj methodSignatureForSelector: selector];
    if(sig == nil) return [obj valueForKey: key];
    NSInvocation* inv = [NSInvocation invocationWithMethodSignature: sig];
    [inv setSelector: selector];
    const char* returnType = [sig methodReturnType];
    [inv invokeWithTarget: obj];
    switch(returnType[0])
    {
        case NSObjCNoType:
        case NSObjCVoidType:
            return nil;
            
        #define T(c,type,Type) case c : { type x = 0; [inv getReturnValue: &x]; return [NSNumber numberWith ## Type : x]; }    
        #define U(c,type,Type) case c : { type unsigned x = 0; [inv getReturnValue: &x]; return [NSNumber numberWithUnsigned ## Type : x]; }    

        T('c',char,Char)
        U('C',char,Char)
        T('s',short,Short)
        U('S',short,Short)
        T('i',int,Int)
        U('I',int,Int)
        T('l',long,Long)
        U('L',long,Long)
        T('f',float,Float)
        T('d',double,Double)
        T('B',bool,Bool)
        T('b',bool,Bool)
        
        case NSObjCObjectType:
        {
            id tmp = nil;
            [inv getReturnValue: &tmp];
            return tmp;
        }
        case NSObjCStringType:
        {
            char* tmp = 0;
            [inv getReturnValue: &tmp];
            return [NSString stringWithUTF8String: tmp];
        }
        case NSObjCSelectorType:
        case NSObjCStructType:
        case NSObjCPointerType:
        case NSObjCArrayType:
        case NSObjCUnionType:
        {
            char buffer[32] = { 0 };
            [inv invokeWithTarget: obj];
            [inv getReturnValue: buffer];
            return [NSValue value:buffer withObjCType:[sig methodReturnType]];
        }
        default:
        {
            return nil;
        }
    }
}

-(void)_copyValuesToObject:(id)object
{
    if([_template isImplied] || [self isGarbage]) return;

    NSArray* slots = [_template slots];
    int i, count = [slots count];
    // object may try to notify of changes - don't listen
    [[self environment] lock];
    for(i = 0; i < count; ++i)
    {
        id keyPath = [[slots objectAtIndex: i] name];
        [object takeValue: [self storedValueForKey: keyPath] forKeyPath: keyPath];
    }
    [[self environment] unlock];
}


-(id)assert
{
    [_template willChangeValueForKey: @"facts"];
    _impl = EnvAssert([[self environment] _impl],_impl);
    [[self object] retain];
    [[_template facts] addObject:self];
    [_template didChangeValueForKey: @"facts"];
    return self;
}

-(id)retract
{
    id obj = [self object];
    [_template willChangeValueForKey: @"facts"];
    [[_template facts] removeObject: self];
    EnvRetract([[self environment] _impl],_impl);
    [obj release];
    [_template didChangeValueForKey: @"facts"];
    return self;
}

// this should cut down on a lot of extra work when all we want to do is update 
// the CLIPS fact.  This method is called by KBEnvironment when processing changes.
// It does NOT remove the object from the KBEnvironment 'modified' list and so calling
// it yourself could result in double rule firings if you don't first remove the object
// from the KBEnvironment's 'modified' list.
-(id)modify
{
    // remember my object
    id obj = [self object];
    [_template willChangeValueForKey: @"facts"];
    
    // we are going to be moving to the end of the list - remove ourselves first
    [[_template facts] removeObject: self];
   
    // remove my fact from CLIPS
    EnvRetract([[self environment] _impl],_impl);
    
    // build a new one that looks just like me
    _impl = EnvCreateFact([[_template environment] _impl],[_template _impl]);
    [_template copyValuesFromObject: obj toFact: self];

    // forget any cached print strings
    [_cachedDescription release]; _cachedDescription = nil;
    [_cachedDescriptionWithIdentifier release]; _cachedDescriptionWithIdentifier = nil;
    
    // assert the new me!
    _impl = EnvAssert([[self environment] _impl],_impl);
    
    // put ourselves at the end of the list
    [[_template facts] addObject:self];
    [_template didChangeValueForKey: @"facts"];
    return self;
}

// This one goes the other way - the clips fact has been modified and we copy from the fact
// to the object.  This method is DEPRECATED as supporting automatic two way sync has been 
// abandoned in favor of always using FScript to manipulate the objects and CLIPS will just
// 'follow along' and trigger actions.  
-(id)modified
{
    [self _copyValuesToObject:[self object]];
    return self;
}

-(void*)_impl 
{
    return _impl; 
}

-(NSString*)descriptionWithIdentifier
{
    if(!_cachedDescriptionWithIdentifier)
    {
        KBRouter* router = [[self environment] routerForName: @"scratch"];
        [router activate];
        [router setDelegate: [[NSMutableString alloc] init]];
        PrintFactWithIdentifier([[self environment] _impl],(char*)[[router name] UTF8String],_impl);
        [router deactivate];
        _cachedDescriptionWithIdentifier = [router delegate];
    }
    return _cachedDescriptionWithIdentifier;
}

-(NSString*)description
{
    if(!_cachedDescription)
    {
        KBRouter* router = [[self environment] routerForName: @"scratch"];
        [router activate];
        [router setDelegate: [[NSMutableString alloc]init]];
        PrintFact([[self environment] _impl],(char*)[[router name] UTF8String],_impl);
        [router deactivate];
        _cachedDescription = [router delegate];
    }
    return _cachedDescription;
}

-(BOOL)isGarbage
{
    return _impl->garbage;
}

-(int)factIndex
{
    return _impl->factIndex;
}

@end
