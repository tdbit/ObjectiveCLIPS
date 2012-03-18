//
//  KBPropertyDescription.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/9/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KBEntityDescription;

@interface KBPropertyDescription : NSObject 
{
    KBEntityDescription*    _entity;
}

-initWithEntityDescription:(KBEntityDescription*)e;

- (NSEntityDescription *)entity;

-(BOOL)isAttribute;
-(BOOL)isRelationship;

@end

@interface NSPropertyDescription (KBPropertyDescription)

-(BOOL)isAttribute;
-(BOOL)isRelationship;

@end