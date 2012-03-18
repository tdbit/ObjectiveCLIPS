/* DataObject.m created by todd on Sat 21-Aug-1999 */

#import <CLIPS/clips.h>

#import "KBDataObject.h"
#import "KBEnvironment.h"
#import "KBString.h"
/*
#define FLOAT                           0
#define INTEGER                         1
#define SYMBOL                          2
#define STRING                          3
#define MULTIFIELD                      4
#define EXTERNAL_ADDRESS                5
#define FACT_ADDRESS                    6
#define INSTANCE_ADDRESS                7 - COOL objects, we're not using these
#define INSTANCE_NAME                   8 - because we have Objective C 
*/


static NSString *dateFormat = @"%Y-%m-%d-+%H:%M:%S";
/* Local Private Helper */

@implementation NSObject (KBSelf)
-(id)self 
{ 
    return self; 
}
-(void)setSelf:(id)obj 
{ 
    //NSAssert(self == obj); 
}
@end

@implementation NSDate (NSCalendarDateGoodies)

-(NSString*)descriptionWithCalendarFormat:(NSString*)fmt
{
    NSCalendarDate* cd = [[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate: [self timeIntervalSinceReferenceDate]];
    return [[cd autorelease] descriptionWithCalendarFormat:fmt];
}

-(id)initWithString:(NSString*) str calendarFormat:(NSString*) fmt
{
    NSCalendarDate* d = [[[NSCalendarDate alloc] initWithString: str calendarFormat: fmt] autorelease];
    return [self initWithTimeIntervalSinceReferenceDate: [d timeIntervalSinceReferenceDate]];
} 

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    obj->type = SYMBOL;
    obj->value = EnvAddSymbol([env _impl],(char*)[[self descriptionWithCalendarFormat: dateFormat] UTF8String]);
}

@end





@implementation NSObject (DataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    obj->type = EXTERNAL_ADDRESS;
    obj->value = self;
}

- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type
{
    switch(*type)
    {
        case NSObjCObjectType:
            value->value.objectValue = self;
            break;
        default:
            [NSException raise: NSInvalidArgumentException format: @"%@",self];
    }
    value->type = *type;
}

+ objectForDataObject: (DATA_OBJECT*) arg inEnvironment:(KBEnvironment*) env
{
    switch(arg->type)
    {
        case FACT_ADDRESS:
        {
            DATA_OBJECT data = { 0 };
            struct fact* aFact = (struct fact*) arg->value;
            if(EnvGetFactSlot([env _impl],aFact,(char*)[@"self" UTF8String],&data))
            {
                return [self objectForDataObject: &data inEnvironment: env];
            }
            else // this is an ordered fact - not a deftemplate fact
            {
                return nil;
            }
        }
        case SYMBOL:
        {
            NSString *str = [NSString stringWithUTF8String: ValueToString(arg->value)];
            if ([str isEqual: @"nil"]) return nil;
            if ([str hasPrefix: @"<<<"] && [str hasSuffix: @">>>"])
            {
                return [NSData dataFromSymbolString: str];
            }
            if ([str isKBDate]) // could be date
            {
                return [[[NSCalendarDate alloc] initWithString: str calendarFormat: dateFormat] autorelease];
            }
            return str;
        }
        case STRING:
        {
            return [NSString stringWithUTF8String: ValueToString(arg->value)]; 
        }
        case INTEGER:
        {
            return [NSNumber numberWithInt: ValueToInteger(arg->value)];
        }
        case FLOAT:
        {
            return [NSNumber numberWithDouble: ValueToDouble(arg->value)];
        }
        case EXTERNAL_ADDRESS:
        {
            return (id) arg->value;
        }
        case MULTIFIELD:
        {
            int i, count = GetpDOLength(arg);
            NSMutableArray *args = [NSMutableArray arrayWithCapacity: count];
            FIELD_PTR fptr = (FIELD_PTR) GetMFPtr(GetpValue(arg),GetpDOBegin(arg));
            for(i = 0; i < count; ++i, ++fptr)
            {
                DATA_OBJECT dobj;
                dobj.type = fptr->type;
                dobj.value = fptr->value;
                [args addObject: [self objectForDataObject: &dobj inEnvironment: env]];
            }
            return args;
        }
        default:
            return nil;
    }
}

- (void) factAssertedInEnvironment:(KBEnvironment*) env
{
    [self retain];
}

- (void) factRetractedFromEnvironment: (KBEnvironment*) env
{
    [self autorelease];
}

@end 

@implementation NSData (DataDataObject)

+ dataFromSymbolString: (NSString *)str
{
    NSString *substr = [str substringWithRange: NSMakeRange(3,[str length]-6)];
    NSMutableData *data = [NSMutableData dataWithCapacity: [substr length]];
    char *ptr = (char *) [substr UTF8String];
    int i = 0;
    char b;
    
    while(*ptr)
    {
        char c = *ptr++;
        if(isalpha(c))
        {
            if (++i % 2)
                b = (((tolower(c) - 'a') + 10) * 16);
            else
            {
                b += (tolower(c) - 'a') + 10;
                [data appendBytes: &b length: 1];
            }
        }
        else if (isdigit(c))
        {
            if (++i % 2)
                b = ((c -'0') * 16);
            else
            {
                b += (c - '0');
                [data appendBytes: &b length: 1];
            }
        }
        else
            continue;
    }
    return data;
}

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    NSString *str = [@"<<" stringByAppendingString: 
        [[self description] stringByRemovingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
    obj->type = SYMBOL;
    obj->value = EnvAddSymbol([env _impl],(char*)[[str stringByAppendingString: @">>"]UTF8String]);
}

- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type
{
    switch(*type)
    {
        case NSObjCObjectType:
            value->value.objectValue = self;
            break;
        case NSObjCStringType:
        case NSObjCPointerType:
        case NSObjCArrayType:
            value->value.pointerValue = (void*)[self bytes];
            break;
        default:
            [NSException raise: NSInvalidArgumentException format: @"%@",self];
    }
    value->type = *type;
}


@end


@implementation NSCalendarDate (DateDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    obj->type = SYMBOL;
    obj->value = EnvAddSymbol([env _impl],(char*)[[self descriptionWithCalendarFormat: dateFormat] UTF8String]);
}

@end

@implementation NSString (StringDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    NSRange r;
    NSMutableCharacterSet *set = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [set addCharactersInString: @"-_"];
    r = [self rangeOfCharacterFromSet: [set invertedSet]];
    
    if (r.length)
    {
        obj->type = STRING;
        obj->value = EnvAddSymbol([env _impl],(char*)[self UTF8String]);
    }
    else
    {
        obj->type = SYMBOL;
        obj->value = EnvAddSymbol([env _impl],(char*)[self UTF8String]);
    }
}

- (BOOL) isKBDate
{
    if ([self length] ==  [@"yyyy-mm-dd-+hh:mm:ss" length])
    {
        const char* str = [self UTF8String];
        if (str[4] == '-' &&
            str[7] == '-' &&
            str[10] == '-' &&
            str[11] == '+' &&
            str[14] == ':' &&
            str[17] == ':')
        {
            if (isdigit(str[0]) &&
                isdigit(str[1]) &&
                isdigit(str[2]) &&
                isdigit(str[3]) &&
                isdigit(str[5]) &&
                isdigit(str[6]) &&
                isdigit(str[8]) &&
                isdigit(str[9]) &&
                isdigit(str[12]) &&
                isdigit(str[13]) &&
                isdigit(str[15]) &&
                isdigit(str[16]) &&
                isdigit(str[18]) &&
                isdigit(str[19])) return YES;
        }

    }
    return NO;
}

- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type
{
    switch(*type)
    {
        case NSObjCObjectType:
            value->value.objectValue = self;
            break;
        case NSObjCStringType:
        case NSObjCPointerType:
        case NSObjCArrayType:
            value->value.cStringLocation = (char*)[self UTF8String];
            break;
        case NSObjCSelectorType:
            value->value.selectorValue = NSSelectorFromString(self);
            break;
        case NSObjCCharType:
            if ([self length] == 1)
            {
                value->value.charValue = *((char*)[self UTF8String]);
                break;
            }
        default:
            [NSException raise: NSInvalidArgumentException format: @"%@",self];
    }
    value->type = *type;
}

-(BOOL)boolValue
{
    NSString* upper = [self uppercaseString];
    return [upper isEqualToString: @"YES"] || [upper isEqualToString: @"TRUE"];
}

@end

@implementation NSNumber (NumberDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    const char* type = [self objCType];
    switch(*type)
    {
        case 'B':
        case 'b':
        {
            obj->type = SYMBOL;
            obj->value = ([self boolValue] ? EnvTrueSymbol([env _impl]) : EnvFalseSymbol([env _impl]));
            break;
        }
        case 'c':
        case 'C':
        {
            obj->type = SYMBOL;
            if([self isBool])
            {
                obj->value = ([self boolValue] ? EnvTrueSymbol([env _impl]) : EnvFalseSymbol([env _impl]));
            }
            else
            {
                char s[] = { [self charValue], 0 };
                obj->value = EnvAddSymbol([env _impl],s);
            }
            break;
        }
        case 'f':
        {
            obj->type = FLOAT;
            obj->value = EnvAddDouble([env _impl],(double)[self floatValue]);
            break;
        }
        case 'd':
        {
            obj->type = FLOAT;
            obj->value = EnvAddDouble([env _impl],[self doubleValue]);
            break;
        }
        default:
        {
            if([self isBool])
            {
                obj->type = SYMBOL;
                obj->value = ([self boolValue] ? EnvTrueSymbol([env _impl]) : EnvFalseSymbol([env _impl]));
            }
            else
            {
                obj->type = INTEGER;
                obj->value = EnvAddLong([env _impl],[self longValue]);
            }
        }
    }
}

- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type
{
    switch(*type)
    {
        case NSObjCObjectType:
            value->value.objectValue = self;
            break;
        case NSObjCCharType:
            value->value.charValue = [self charValue];
            break;
        case NSObjCShortType:
            value->value.shortValue = [self shortValue];
            break;
        case 'i':
            value->value.longValue = (long)[self intValue];
            break;
        case NSObjCLongType:
            value->value.longValue = [self longValue];
            break;
        case NSObjCLonglongType:
            value->value.longlongValue = [self longLongValue];
            break;
        case NSObjCFloatType:
            value->value.floatValue = [self floatValue];
            break;
        case NSObjCDoubleType:
            value->value.doubleValue = [self doubleValue];
            break;
        default:
            [NSException raise: NSInvalidArgumentException format: @"%@",self];
    }
    value->type = *type;
}

- (BOOL) isBool
{
    static NSNumber* trueValue = nil;
    static NSNumber* falseValue = nil;
    if(!trueValue)
    {
        trueValue = [NSNumber numberWithBool: YES];
        falseValue = [NSNumber numberWithBool: NO];
    }
    return (self == trueValue || self == falseValue);
}

@end

@implementation NSArray (ArrayDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
{
    DATA_OBJECT temp;
    int i;

    obj->type = MULTIFIELD;
    obj->value = EnvCreateMultifield([env _impl],[self count]);
    for(i = 0; i < [self count]; ++i)
    {
        [[self objectAtIndex: i] dataObject: &temp inEnvironment: env];
        SetMFType(obj->value,i+1,temp.type);
        SetMFValue(obj->value,i+1,temp.value);
    }
    SetDOBegin(*obj,1);
    SetDOEnd(*obj,[self count]);
}

- (void) factAssertedInEnvironment: (KBEnvironment*) env
{
    int i, count = [self count];
    for(i = 0; i < count; ++i)
    {
        [[self objectAtIndex: i] factAssertedInEnvironment: env];
    }
}

- (void) factRetractedFromEnvironment: (KBEnvironment*) env
{
    int i, count = [self count];
    for(i = 0; i < count; ++i)
    {
        [[self objectAtIndex: i] factRetractedFromEnvironment: env];
    }
}

@end

@implementation NSObject (KBBinaryData)

-(id)fromBinary 
{ 
    return self; 
}

-(NSData*)toBinary 
{ 
    return [NSArchiver archivedDataWithRootObject: self]; 
}

@end

@implementation NSData (KBBinaryData)

-(id)fromBinary 
{ 
    return [NSUnarchiver unarchiveObjectWithData: self]; 
}

-(NSData*)toBinary 
{ 
    return self; 
}

@end