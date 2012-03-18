/*
 *  KBActivation.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd  Blanchard on 9/22/05.
 *  Copyright 2005 Black Bag Operations Network. All rights reserved.
 *
 */

#import <ObjectiveCLIPS/KBEnvironment.h>
#import <CLIPS/agenda.h>

@class KBRule;

@interface KBActivation : NSObject 
{
    KBEnvironment* _environment;
    ACTIVATION* _impl;
}

+activationWithEnvironment:(KBEnvironment*)env implementation:(void*)impl;
-initWithEnvironment:(KBEnvironment*)env implementation:(void*)impl;

-(KBEnvironment*)environment;

-(KBRule*)rule;
-(int)salience;

-(NSString*)description;

-(void*)_impl;
@end

/*
struct activation
  {
   struct defrule *theRule;
   struct partialMatch *basis;
   int salience;
   unsigned long int timetag;
#if CONFLICT_RESOLUTION_STRATEGIES
   struct partialMatch *sortedBasis;
   int randomID;
#endif
   struct activation *prev;
   struct activation *next;
  };

*/