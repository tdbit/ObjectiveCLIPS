//
//  KBRelationshipDescription.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/9/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBRelationshipDescription.h"


@implementation KBRelationshipDescription

- (BOOL)isToMany
{
    return _isToMany;
}

-(BOOL)isRelationship
{
    return YES;
}

@end

@implementation NSRelationshipDescription (KBRelationshipDescription)

-(BOOL)isRelationship
{
    return YES;
}

@end