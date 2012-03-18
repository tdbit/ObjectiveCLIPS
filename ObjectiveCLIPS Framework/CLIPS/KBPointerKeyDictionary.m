//
//  KBPointerKeyDictionary.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sun Sep 29 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import "KBPointerKeyDictionary.h"


@implementation KBPointerKeyDictionary

+dictionary
{
    return [[[self alloc] init] autorelease];
}

+dictionaryWithCapacity:(unsigned)capacity
{
    return [[[self alloc] initWithCapacity:capacity] autorelease];
}

+dictionaryWithCapacity:(unsigned) capacity weakReferences:(BOOL)yorn
{
    return [[[self alloc] initWithCapacity:capacity weakReferences:yorn] autorelease];
}

-init
{
    return [self initWithCapacity: 19];
}

-initWithCapacity:(unsigned) capacity
{
    return [self initWithCapacity: capacity weakReferences: NO];
}

-initWithCapacity:(unsigned) capacity weakReferences:(BOOL)yorn
{
    if(self = [super init])
    {
        if(yorn)
        {
            _map = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks,
                                    NSNonRetainedObjectMapValueCallBacks,capacity,[self zone]);
        }
        else
        {
            _map = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks,
                                    NSObjectMapValueCallBacks,capacity,[self zone]);        
        }
    }
    return self;
}

-(void)dealloc
{
    [self removeAllObjects];
    NSFreeMapTable(_map);
    [super dealloc];
}

-(void)setObject:(id)object forKey:(void*)key
{
    NSMapInsert(_map,key,object);
}

-(void)removeObjectForKey:(void*)key
{
    NSMapRemove(_map,key);
}

-(id)objectForKey:(void*)key
{
    return NSMapGet(_map,key);
}

-(NSArray*)allValues
{
    return NSAllMapTableValues(_map);
}

-(unsigned)count
{
    return NSCountMapTable(_map);
}

-(void)removeAllObjects
{
    NSResetMapTable(_map);
}

-(id)firstValueMatchingValue:(id) value atKeyPath:(NSString*)keyPath
{
    int i;
    NSArray* values = [self allValues];
    int count = [values count];
    for(i = 0; i < count; ++i)
    {
        id object = [values objectAtIndex: i];
        id objectValue = [object valueForKeyPath: keyPath];
        if([objectValue isEqual: value]) return object;
    }
    return nil;
}

@end
