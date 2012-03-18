//
//  KBTemplateSlot.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 21 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/setup.h>
#import <CLIPS/tmpltutl.h>

#import "KBTemplateSlot.h"
#import "KBTemplate.h"
#import "KBEnvironment.h"
#import "KBFact.h"
#import "KBAttributeDescription.h"
#import "KBRelationshipDescription.h"
#import "KBString.h"
#import "KBDataObject.h"

static NSString *dateFormat = @"%Y-%m-%d-+%H:%M:%S";

@implementation KBTemplateSlot

+slotWithTemplate:(KBTemplate*)deftemplate implementation:(void*) impl
{
    return [[[self alloc] initWithTemplate: deftemplate implementation: impl] autorelease];
}

-(id)initWithTemplate:(KBTemplate*) deftemplate implementation:(void*) impl
{
    if(self = [self init])
    {
        if(!impl)
        {
            [self autorelease];
            [NSException raise: @"KBInvalidSlotException"
                                        format: @"deftemplate: %@\n",
                                    [deftemplate name]];
        }
        _template = deftemplate;
        _impl = (struct templateSlot*) impl;
        [self setName: [NSString stringWithUTF8String: _impl->slotName->contents]];    
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}


-(KBTemplate *)template
{
    return _template;
}

-(BOOL)isMultiSlot
{
    return _impl->multislot != 0;
}

-(id)propertyDescription
{
    return _propertyDescription;
}

-(void)setPropertyDescription:(id)desc
{
    _propertyDescription = desc;
}

-(int)type
{
    return [[self propertyDescription] attributeType];
}

-(NSString*)description
{
    if([self isMultiSlot])
        return [NSString stringWithFormat: @"(multifield %@)",[self name]];
    else
        return [NSString stringWithFormat: @"(field %@)",[self name]];
}

-(void*)_impl
{
    return _impl;
}

-(void)copyFromObject:(id)obj toFact:(KBFact*) fact
{
    DATA_OBJECT data = { 0, RVOID };
    NSString* keyPath = [self name];
    void* env = [[fact environment] _impl];
    
    if([keyPath isEqualToString: @"self"])
    {
        data.type = EXTERNAL_ADDRESS;
        data.value = obj;
    }
    else if([self isMultiSlot])
    {
        id value = [obj valueForKeyPath: keyPath];
                
        if(!value)
        {
            data.type = SYMBOL;
            data.value = EnvAddSymbol(env,"nil");
        }
        else
        {
            if([value isKindOfClass: [NSSet class]])
            {
                value = [value allObjects];
            }

            NSArray* array = (([value isKindOfClass: [NSArray class]] || value == nil) ? value : [NSArray arrayWithObject: value]);
            int i, count = [array count];

            data.type = MULTIFIELD;
            data.value = EnvCreateMultifield(env,count);
            for(i = 0; i < count; ++i)
            {
                SetMFType(data.value,i+1,EXTERNAL_ADDRESS);
                SetMFValue(data.value,i+1,[array objectAtIndex: i]);
            }
            SetDOBegin(data,1);
            SetDOEnd(data,count);
        }
    }
    else if([[self propertyDescription] isRelationship])
    {
        id value = [obj valueForKeyPath: keyPath];
        
        if(!value)
        {
            data.type = SYMBOL;
            data.value = EnvAddSymbol(env,"nil");
        }
        else        
        {
            data.type = EXTERNAL_ADDRESS;
            data.value = value;
        }
    }
    else
    {
        id value = [obj valueForKeyPath: keyPath];
        
        if(!value)
        {
            data.type = SYMBOL;
            data.value = EnvAddSymbol(env,"nil");
        }
        else
        {
            NSAttributeType type = [[self propertyDescription] attributeType];
            switch(type)
            {
                case NSInteger16AttributeType: 
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                case NSDecimalAttributeType:
                {
                    data.type = INTEGER;
                    data.value = EnvAddLong(env,[[obj valueForKeyPath: keyPath] longValue]);
                    break;
                }
                case NSDoubleAttributeType:
                {
                    data.type = FLOAT;
                    data.value = EnvAddDouble(env,[value doubleValue]);
                    break;
                }
                case NSFloatAttributeType:
                {
                    data.type = FLOAT;
                    data.value = EnvAddDouble(env,(double)[value floatValue]);
                    break;
                }
                case NSStringAttributeType:
                {
                    NSRange r;
                    NSMutableCharacterSet *set = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
                    [set addCharactersInString: @"-_"];
                    r = [value rangeOfCharacterFromSet: [set invertedSet]];
        
                    if (r.length)
                    {
                        data.type = STRING;
                        data.value = EnvAddSymbol(env,(char*)[value UTF8String]);
                    }
                    else
                    {
                        data.type = SYMBOL;
                        data.value = EnvAddSymbol(env,(char*)[value UTF8String]);
                    }
                    break;
                }
                case NSBooleanAttributeType:
                {
                    data.type = SYMBOL;
                    data.value = ([value boolValue] ? EnvTrueSymbol(env) : EnvFalseSymbol(env));
                    break;
                }
                case NSDateAttributeType:
                {
                    data.type = SYMBOL;
                    data.value = EnvAddSymbol(env,(char*)[[value descriptionWithCalendarFormat: dateFormat] UTF8String]);
                    break;
                }
                case NSBinaryDataAttributeType:
                {
                    NSString *str = [@"<<" stringByAppendingString: 
                    [[value description] stringByRemovingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
                    data.type = SYMBOL;
                    data.value = EnvAddSymbol(env,(char*)[[str stringByAppendingString: @">>"]UTF8String]);
                    break;
                }
                default: // shouldn't happen - but if we get here - best to just set nil
                {
                    data.type = SYMBOL;
                    data.value = EnvAddSymbol(env,"nil");
                    break;
                }
            }
        }
    }
    if(!EnvPutFactSlot(env,[fact _impl],(char*)[keyPath UTF8String],&data))
    {
        [NSException raise: @"Invalid Fact Slot: " format:@"%@ does not exist.",keyPath];
    }
}

-(void)copyFromFact:(KBFact*)fact toObject:(id)object
{
    DATA_OBJECT data = { 0 };
    void* env = [[_template environment]_impl];
    id value = nil;
    
    if(EnvGetFactSlot(env,[fact _impl],(char*)[[self name] UTF8String],&data))
    {
        value = [NSObject objectForDataObject:&data inEnvironment:[_template environment]];
        if([[object valueForKeyPath: [self name]] isEqualTo: value])
        {
            [object setValue: value forKeyPath: [self name]];
        }
    }
}

@end
