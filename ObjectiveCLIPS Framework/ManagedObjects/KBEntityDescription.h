//
//  KBEntityDescription.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NSEntityDescription;
@class KBObjectModel;

@interface KBEntityDescription : NSObject 
{
    Class           _entity;
    KBObjectModel*  _model;
    NSDictionary*   _attributes;
}

+descriptionWithClass:(Class)cls model:(KBObjectModel*)mdl;
-initWithClass:(Class)cls model:(KBObjectModel*)mdl;

- (NSManagedObjectModel *)managedObjectModel;

- (NSString *)managedObjectClassName;
- (NSString *)name;

- (NSDictionary *)attributesByName;

- (NSDictionary *)propertiesByName;
- (NSArray *)properties;

-(NSString*)deftemplateString;

@end

@interface NSEntityDescription (KBEntityDescription)

-(NSString*)deftemplateString;

@end