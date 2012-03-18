/* DataObject.h created by todd on Sat 21-Aug-1999 */


#import <CLIPS/clips.h>

#import <Foundation/Foundation.h>

enum _NSObjCValueType {
    NSObjCNoType = 0,
    NSObjCVoidType = 'v',
    NSObjCCharType = 'c',
    NSObjCShortType = 's',
    NSObjCLongType = 'l',
    NSObjCLonglongType = 'q',
    NSObjCFloatType = 'f',
    NSObjCDoubleType = 'd',
    NSObjCBoolType = 'B',
    NSObjCSelectorType = ':',
    NSObjCObjectType = '@',
    NSObjCStructType = '{',
    NSObjCPointerType = '^',
    NSObjCStringType = '*',
    NSObjCArrayType = '[',
    NSObjCUnionType = '(',
    NSObjCBitfield = 'b'
};

typedef struct {
    NSInteger type;
    union {
    	char charValue;
        short shortValue;
        long longValue;
        long long longlongValue;
        float floatValue;
        double doubleValue;
        bool boolValue;
        SEL selectorValue;
        id objectValue;
        void *pointerValue;
        void *structLocation;
        char *cStringLocation;
    } value;
} NSObjCValue;



@class KBEnvironment;

@interface NSObject (KBSelf)
-(id)self;
-(void)setSelf:(id)obj;
@end

@interface NSObject (KBBinaryData)

-(id)fromBinary;
-(NSData*)toBinary; 

@end

@interface NSObject (DataObject)

+ objectForDataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment*) env;
- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type;

// Notification Methods
- (void) factAssertedInEnvironment:(KBEnvironment*) env;
- (void) factRetractedFromEnvironment: (KBEnvironment*) env;
@end

@interface NSData (DataDataObject)

+ dataFromSymbolString: (NSString *)str;
- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type;

@end

@interface NSCalendarDate (DateDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;

@end

@interface NSString (StringDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
- (BOOL) isKBDate;
- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type;

@end

@interface NSNumber (NumberDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
- (void) getNSObjCValue: (NSObjCValue *) value asType: (const char*) type;
- (BOOL) isBool;

@end

@interface NSArray (ArrayDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;
// Notification Methods
- (void) factAssertedInEnvironment:(KBEnvironment*) env;
- (void) factRetractedFromEnvironment: (KBEnvironment*) env;

@end
