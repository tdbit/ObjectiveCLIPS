//
//  KBTemplateSlot.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveCLIPS/KBNamedObject.h>

struct templateSlot;
@class KBTemplate;
@class KBFact;

/*
struct templateSlot {
   struct symbolHashNode *slotName;
   unsigned int multislot : 1;
   unsigned int noDefault : 1;
   unsigned int defaultPresent : 1;
   unsigned int defaultDynamic : 1;
   CONSTRAINT_RECORD *constraints;
   struct expr *defaultList;
   struct templateSlot *next;
}

*/

@interface KBTemplateSlot : KBNamedObject 
{
    KBTemplate*				_template;
    struct templateSlot*	_impl;
    id                      _propertyDescription;
}

+(id)slotWithTemplate:(KBTemplate*)deftemplate implementation:(void*) impl;
-(id)initWithTemplate:(KBTemplate*) deftemplate implementation:(void*) impl;

-(id)propertyDescription;
-(void)setPropertyDescription:(id)desc;

-(void)copyFromObject:(id)obj toFact:(KBFact*) fact;

-(KBTemplate*)template;
-(BOOL)isMultiSlot;

-(int)type;

-(void*)_impl;

@end