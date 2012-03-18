//
//  KBFact.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KBEnvironment;
@class KBTemplate;
struct fact;

@interface KBFact : NSObject 
{
    KBTemplate*	_template;
    NSString*   _cachedDescription;
    NSString*   _cachedDescriptionWithIdentifier;
    struct fact*_impl;
}

+factWithTemplate:(KBTemplate*) tem object:(id) obj;
+factWithTemplate:(KBTemplate*) tem implementation:(struct fact*) impl;
+factWithEnvironment:(KBEnvironment*)env implementation:(struct fact*) impl;

-initWithTemplate:(KBTemplate*) tem object:(id) obj;
-initWithTemplate:(KBTemplate*) tem implementation:(void*) impl;

-(KBTemplate*)template;
-(KBEnvironment*)environment;

-(unsigned long)index;
-(id)object;

// they do the CLIPS equivalents
-(id)assert;
-(id)retract;
-(id)modify;

// should be deprecated
//-(id)modified;

-(BOOL)isGarbage;

-(void)_copyValuesToObject:(id)object;

-(void*) _impl;
-(NSString*)descriptionWithIdentifier;
@end
