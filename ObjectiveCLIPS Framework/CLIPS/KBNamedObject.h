/*
 *  KBNamedObject.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd Blanchard on 5/20/05.
 *  Copyright 2005 Todd Blanchard. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface KBNamedObject : NSObject
{
    NSString* _name;
}

-initWithName:(NSString*)name;

-(NSString*)name;
-(void)setName:(NSString*)name;

@end