//
//  KBConstruct.m
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 2/24/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import "KBConstruct.h"
#import "KBConstructColorizer.h"


@implementation KBConstruct

+(void)hookConstructInEnvironment:(KBEnvironment*) env
{
    NSLog([NSString stringWithFormat: @"WARNING: %@ +hookConstructInEnvironment: notImplemented.",[self className]]);
}

+(void)unhookConstructInEnvironment:(KBEnvironment*) env
{
    NSLog([NSString stringWithFormat: @"WARNING: %@ +unhookConstructInEnvironment: notImplemented.",[self className]]);
}

-(void)dealloc
{
    [_attributedDescription release];
    [super dealloc];
}

-(NSAttributedString*)attributedDescription
{
    if(!_attributedDescription)
    {
        KBConstructColorizer* colorizer = [KBConstructColorizer colorizer];
        _attributedDescription = [[colorizer colorizeString: [self description]]retain];
    }
    return _attributedDescription;
}

-(void)setAttributedDescription:(NSAttributedString*)str {}

@end
