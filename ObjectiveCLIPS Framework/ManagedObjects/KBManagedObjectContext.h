//
//  KBManagedObjectContext.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 5/23/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@class KBEnvironment;

@interface KBManagedObjectContext : NSManagedObjectContext 
{
    KBEnvironment*  _environment;
}

-(KBEnvironment*)environment;
-(void)defineTemplatesFromModel;

@end
