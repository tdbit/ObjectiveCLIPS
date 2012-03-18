//
//  KBAttributeDescription.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSAttributeDescription.h>
#import <ObjectiveCLIPS/KBPropertyDescription.h>
#import <objc/objc-class.h>
#import <objc/objc.h>

@class KBEntityDescription;
@class KBFact;

@interface KBAttributeDescription : KBPropertyDescription 
{
    Ivar                    _ivar;
}

+descriptionWithEntityDescription:(KBEntityDescription*)e ivar:(Ivar) iv;
-initWithEntityDescription:(KBEntityDescription*)e ivar:(Ivar) iv;

-(NSString*)name;
-(NSAttributeType)attributeType;
-(const char*)objCType;

-(BOOL)isAttribute;

@end

@interface NSAttributeDescription (KBAttributeDescription)

//attributeType and name are already implemented
-(const char*)objCType;

-(BOOL)isAttribute;

@end