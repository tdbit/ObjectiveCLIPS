//
//  KBEntityDescription.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBEntityDescription.h"
#import <objc/objc-class.h>
#import <objc/objc.h>
#import "KBAttributeDescription.h"


@implementation KBEntityDescription
{
//    Class           _entity;
//    KBObjectModel*  _model;
//    NSDictionary*   _attributes;
}

+descriptionWithClass:(Class)cls model:(KBObjectModel*)mdl
{
    return [[[self alloc]initWithClass: cls model: mdl]autorelease];
}

-initWithClass:(Class) cls model:(KBObjectModel*)mdl
{
    if(self = [self init])
    {
        // retain nothing
        _entity = cls;
        _model = mdl;
    }
    return self;
}

-(void)dealloc
{
    [_attributes release];
    [super dealloc];
}

- (NSManagedObjectModel *)managedObjectModel
{
    return (NSManagedObjectModel*)_model;
}

- (NSString *)managedObjectClassName
{
    return [self name];
}

- (NSString *)name
{
    return NSStringFromClass(_entity);
}

- (NSDictionary *)attributesByName
{
    if(!_attributes)
    {
        Class cls = _entity;

        #if !__OBJC2__
        if(!cls || !cls->ivars) return (_attributes = [NSDictionary new]);
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: cls->ivars->ivar_count];
        int i;
        for(i = 0; i < cls->ivars->ivar_count; ++i)
        {
            Ivar ivar = &(cls->ivars->ivar_list[i]);
            KBAttributeDescription* desc = [KBAttributeDescription descriptionWithEntityDescription: self ivar: ivar];
            [dict setObject: desc forKey: [desc name]]; 
        }
        #else 
        unsigned int ivar_count = 0;
        Ivar *ivar_list = class_copyIvarList(cls, &ivar_count);
        if(!cls || !ivar_count) return (_attributes = [NSDictionary new]);
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:ivar_count];
        int i;
        for(i = 0; i < ivar_count; ++i)
        {
            Ivar ivar = ivar_list[i];
            KBAttributeDescription* desc = [KBAttributeDescription descriptionWithEntityDescription: self ivar: ivar];
            [dict setObject: desc forKey: [desc name]]; 
        }        
        #endif
        
        _attributes = [[NSDictionary alloc]initWithDictionary:dict];
    }
    return _attributes;
}

- (NSDictionary *)propertiesByName
{
    return [self attributesByName];
}

- (NSArray *)properties
{
    return [[self attributesByName]allValues];
}

-(NSString*)deftemplateString
{
    NSMutableString* def = [NSMutableString stringWithString: @"(deftemplate "];
    NSArray* properties = [self properties];
    int i, count = [properties count];
    [def appendString: [self name]];
    [def appendString: @"\n    (field self)\n"];
    for(i = 0; i < count; ++i)
    {
        NSPropertyDescription* prop = [properties objectAtIndex: i];
        NSString* fieldDef = [[prop userInfo] objectForKey: @"deftemplate"];
        
        if(fieldDef)
        {
            [def appendString: @"    "];
            [def appendString: fieldDef];
            [def appendString: @"\n"];
        }
        else
        {
            [def appendString: @"    ("];
            if([prop isRelationship] && [(NSRelationshipDescription*) prop isToMany])
            {
                [def appendString: @"multi"];
            }
            [def appendString: @"field "];
            [def appendString: [prop name]];
            [def appendString: @")\n"];
        }
    }
    [def appendString: @")"];
    return def;
}

@end

@implementation NSEntityDescription (KBEntityDescription)

-(NSString*)deftemplateString
{
    NSMutableString* def = [NSMutableString stringWithString: @"(deftemplate "];
    NSArray* properties = [self properties];
    int i, count = [properties count];
    [def appendString: [self name]];
    [def appendString: @"\n    (field self)\n"];
    for(i = 0; i < count; ++i)
    {
        NSPropertyDescription* prop = [properties objectAtIndex: i];
        [def appendString: @"    ("];
        if([prop isRelationship] && [(NSRelationshipDescription*)prop isToMany])
        {
            [def appendString: @"multi"];
        }
        [def appendString: @"field "];
        [def appendString: [prop name]];
        [def appendString: @")\n"];
    }
    [def appendString: @")"];
    return def;
}

@end
