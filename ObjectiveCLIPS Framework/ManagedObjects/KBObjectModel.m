//
//  KBObjectModel.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBObjectModel.h"
#import "KBTemplate.h"
#import "KBEnvironment.h"
#import "KBEntityDescription.h"

@implementation KBObjectModel : NSObject 

-init
{
    if(self = [super init])
    {
        _entities = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc
{
    [_entities release];
    [super dealloc];
}

-(id)entityForName:(NSString*)name
{
    KBEntityDescription* desc = [_entities objectForKey: name];
    if(!desc)
    {
        Class cls = NSClassFromString(name);
        if(cls)
        {
            desc = [KBEntityDescription descriptionWithClass: cls model: self];
            [_entities setObject: desc forKey: name];
            return desc;
        }
    }
    return nil;
}

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env
{
    NSEntityDescription* entity = [self entityForName: name];
    NSString* deftemplate = [entity deftemplateString];
    if(deftemplate)
    {
        [env performCommand: deftemplate];
        KBTemplate* tmpl = [env templateForName: name];
        [tmpl setEntityDescription: entity];
        return tmpl;
    }
    return nil;
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
@end

@implementation NSManagedObjectModel (KBManagedObjectModel)

-(id)entityForName:(NSString*)name
{
    return [[self entitiesByName] objectForKey: name];
}

-(KBTemplate*) templateForName: (NSString *)name inEnvironment:(KBEnvironment*) env
{
    NSEntityDescription* entity = [[self entitiesByName] objectForKey: name];
    NSString* deftemplate = [entity deftemplateString];
    if(deftemplate)
    {
        [env performCommand: deftemplate];
        KBTemplate* tmpl = [env templateForName: name];
        [tmpl setEntityDescription: entity];
        return tmpl;
    }
    return nil;
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

@end