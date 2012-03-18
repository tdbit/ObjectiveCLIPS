//
//  KBManagedObjectContext.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 5/23/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBManagedObjectContext.h"
#import "KBEnvironment.h"
#import "KBTemplate.h"
#import "KBEntityDescription.h"

@implementation KBManagedObjectContext

-(KBEnvironment*)environment
{
    if(!_environment)
    {
        _environment = [KBEnvironment new];
    }
    return _environment;
}

-(void)defineTemplatesFromModel
{
    NSArray* entities = [[[self persistentStoreCoordinator]managedObjectModel]entities];
    int i, count = [entities count];
    
    // load up the templates early so rule loading works fine
    for(i = 0; i < count; ++i)
    {
        [_environment templateForName: [[entities objectAtIndex: i] name]];
    }    
}

-(void)dealloc
{
    [_environment release];
    [super dealloc];
}

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env
{
	if([_environment extraLogging])NSLog(@"%@ %@ entry, name = %@",[self className],NSStringFromSelector( _cmd ), name);
    NSManagedObjectModel* model = [[self persistentStoreCoordinator]managedObjectModel];
    return [model templateForName: name inEnvironment: env];
}

-(KBTemplate*) templateForObject:(id)obj inEnvironment:(KBEnvironment*) env
{
    if([obj respondsToSelector: @selector(entity)])
    {
        NSEntityDescription* entity = [obj entity];
        return [env templateForName: [entity name]]; 
    }
    return [env templateForName: [obj className]];
}

-(void)reset
{
    [[self environment]reset];
    [super reset];
}

@end
