//
//  KBPointerKeyDictionary.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sun Sep 29 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>

// cheap wrapper for NSMapTable
@interface KBPointerKeyDictionary : NSObject 
{
    NSMapTable*	_map;
}

+dictionary;
+dictionaryWithCapacity:(unsigned)capacity;
+dictionaryWithCapacity:(unsigned) capacity weakReferences:(BOOL)yorn;

-initWithCapacity:(unsigned) capacity;
-initWithCapacity:(unsigned) capacity weakReferences:(BOOL)yorn;

-(void)setObject:(id)object forKey:(void*)key;
-(void)removeObjectForKey:(void*)key;
-(id)objectForKey:(void*)key;
-(NSArray*)allValues;
-(unsigned)count;
-(void)removeAllObjects;
-(id)firstValueMatchingValue:(id) value atKeyPath:(NSString*)keyPath;

@end
