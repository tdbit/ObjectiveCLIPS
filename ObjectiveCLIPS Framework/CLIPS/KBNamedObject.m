//
//  KBNamedObject.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 5/20/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <ObjectiveCLIPS/KBNamedObject.h>


@implementation KBNamedObject

-initWithName:(NSString*)name
{
    if(self = [super init])
    {
        [self setName: name];
    }
    return self;
}

-(void)dealloc
{
    [_name release];
    [super dealloc];
}

-(NSString*)name
{
    return _name;
}

-(void)setName:(NSString*)name
{
    [name retain];
    [_name release];
    _name = name;
}

-(void)setDescription:(NSString*)str
{
}

@end
