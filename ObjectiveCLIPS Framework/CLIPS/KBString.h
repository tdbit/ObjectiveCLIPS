/*
 *  KBString.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd Blanchard on 6/14/05.
 *  Copyright 2005 Todd Blanchard. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@interface NSString (StringByRemovingCharactersInSet)

-(NSString *)stringByRemovingCharactersInSet: (NSCharacterSet *) set;

@end