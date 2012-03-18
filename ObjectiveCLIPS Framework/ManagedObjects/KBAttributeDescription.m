//
//  KBAttributeDescription.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBAttributeDescription.h"

@implementation KBAttributeDescription

+descriptionWithEntityDescription:(KBEntityDescription*)e ivar:(Ivar) iv
{
    return [[[self alloc]initWithEntityDescription: e ivar: iv]autorelease];
}

-initWithEntityDescription:(KBEntityDescription*)e ivar:(Ivar) iv
{
    if(self = [self initWithEntityDescription: e])
    {
        _ivar = iv;
    }
    return self;
}

-(NSString*)name
{
#if !__OBJC2__
    return [NSString stringWithUTF8String: _ivar->ivar_name];
#else
    return [NSString stringWithUTF8String:ivar_getName(_ivar)];
#endif
}

-(NSAttributeType)attributeType
{
    const char* type = [self objCType];
    switch(*type)
    {
        case 'b': // bit
        case 'B': // bool
            return NSBooleanAttributeType;
        case 's':
        case 'S':
            return NSInteger16AttributeType;
        case 'i':
        case 'I':
        case 'l':
        case 'L':
            return NSInteger32AttributeType;
        case 'q':
        case 'Q':
            return NSInteger64AttributeType;
        case 'd':
            return NSDoubleAttributeType;
        case 'f':
            return NSFloatAttributeType;
        case '@':
            return NSStringAttributeType;
        default:
            return 0;
    }
}
#if 0
    NSUndefinedAttributeType = 0,
    NSInteger16AttributeType = 100,
    NSInteger32AttributeType = 200,
    NSInteger64AttributeType = 300,
    NSDecimalAttributeType = 400,
    NSDoubleAttributeType = 500,
    NSFloatAttributeType = 600,
    NSStringAttributeType = 700,
    NSBooleanAttributeType = 800,
    NSDateAttributeType = 900,
    NSBinaryDataAttributeType = 1000
#endif

-(const char*)objCType
{
#if !__OBJC2__
    return _ivar->ivar_type;
#else
    return ivar_getTypeEncoding(_ivar);
#endif
}

-(BOOL)isAttribute
{
    return YES;
}

@end

@implementation NSAttributeDescription (KBAttributeDescription)

-(const char*)objCType
{
    switch([self attributeType])
    {
        case NSInteger16AttributeType: 
            return "s";
        case NSInteger32AttributeType:
            return "i";
        case NSInteger64AttributeType:
            return "q";
        case NSDecimalAttributeType:
            return "l";
        case NSDoubleAttributeType:
            return "d";
        case NSFloatAttributeType:
            return "f";
        case NSStringAttributeType:
            return "@";
        case NSBooleanAttributeType:
            return "B";
        case NSDateAttributeType:
            return "@";
        case NSBinaryDataAttributeType:
            return "@";
        default:
            return "?";
    }
}

-(BOOL)isAttribute
{
    return YES;
}

@end