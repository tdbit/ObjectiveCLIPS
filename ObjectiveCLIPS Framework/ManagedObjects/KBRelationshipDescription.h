//
//  KBRelationshipDescription.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/9/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ObjectiveCLIPS/KBPropertyDescription.h>

@interface KBRelationshipDescription : KBPropertyDescription 
{
    NSString* _name;
    BOOL _isToMany;
}



- (BOOL)isToMany;

-(BOOL)isRelationship;

@end

@interface NSRelationshipDescription (KBRelationshipDescription)

//- (BOOL)isToMany

-(BOOL)isRelationship;

@end