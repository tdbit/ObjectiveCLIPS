//
//  KBManagedObject.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 5/23/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@class KBEnvironment;
@class KBFact;

@interface KBManagedObject : NSManagedObject 
{
    KBEnvironment* _environment;
}

// Convenience methods
-(KBEnvironment*)environment;
-(KBFact*)fact;

// hooked to make certain we assert for CLIPS
-(void)awakeFromFetch;
-(void)awakeFromInsert;

// if the object validates for delete - it will be retracted because this is
// the only place I could find to intercept that action.
// The others only call super and are here for convenience
- (BOOL)validateForDelete:(NSError **)error;
- (BOOL)validateForInsert:(NSError **)error;
- (BOOL)validateForUpdate:(NSError **)error;

@end
