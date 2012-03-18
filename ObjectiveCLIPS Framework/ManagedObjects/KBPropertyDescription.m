//
//  KBPropertyDescription.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/9/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBPropertyDescription.h"

@implementation KBPropertyDescription

-initWithEntityDescription:(KBEntityDescription*)e
{
    if(self = [super init])
    {
        _entity = e;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

-(id)entity
{
    return _entity;
}

-(BOOL)isAttribute
{
    return NO;
}

-(BOOL)isRelationship
{
    return NO;
}

@end

@implementation NSPropertyDescription (KBPropertyDescription)

-(BOOL)isAttribute
{
    return NO;
}

-(BOOL)isRelationship
{
    return NO;
}


@end
