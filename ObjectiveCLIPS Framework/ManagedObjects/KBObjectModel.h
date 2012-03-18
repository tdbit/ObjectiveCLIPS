//
//  KBObjectModel.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KBTemplate;
@class KBEnvironment;

@interface KBObjectModel : NSObject 
{
    NSMutableDictionary* _entities;
}

-(id)entityForName:(NSString*)name;

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env;
-(KBTemplate*) templateForObject:(id)obj inEnvironment:(KBEnvironment*) env;

@end

@interface NSManagedObjectModel (KBManagedObjectModel)

-(id)entityForName:(NSString*)name;

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env;
-(KBTemplate*) templateForObject:(id)obj inEnvironment:(KBEnvironment*) env;

@end