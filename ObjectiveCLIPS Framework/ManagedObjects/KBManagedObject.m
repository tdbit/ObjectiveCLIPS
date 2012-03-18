//
//  KBManagedObject.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 5/23/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBManagedObject.h"
#import "KBManagedObjectContext.h"
#import "KBEnvironment.h"
#import <FScript/FScript.h>

#if 0
// helpers
static NSString* mutatorForKey(NSString* key)
{
    return [NSString stringWithFormat: @"set%@%@:",
        [[key substringWithRange: NSMakeRange(0,1)] capitalizedString],
        [key substringWithRange: NSMakeRange(1,[key length]-1)]];
}

static NSString* keyForMutator(NSString* key)
{
    if([key hasPrefix: @"set"])
    {
        key = [[[key substringWithRange: NSMakeRange(3,1)] lowercaseString] 
                stringByAppendingString: [key substringWithRange: NSMakeRange(4,[key length]-5)]];
    }
    return key;
}

#endif

@implementation KBManagedObject

-(id)copyWithZone:(NSZone*)zone
{
    return [self retain];
}

-(BOOL)isEqualToString:(NSString*)string
{
    NSLog(@"Huh?");
    return NO;
}

-(KBEnvironment*)environment
{
    if(!_environment)
    {
        id ctxt = [self managedObjectContext];
        // apparently the context isn't always the one you started with - have to guard against that.
        if([ctxt respondsToSelector:@selector(environment)])
        {
            _environment = [ctxt environment];
        }
    }
    return _environment;
}

-(KBFact*)fact
{
    return [[self environment] factForObject: self];
}

-(void)dealloc
{
    [super dealloc];
}

-(void)awakeFromFetch
{
	if([_environment extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    [super awakeFromFetch];
    [[self environment] assertObject: self];
}

-(void)awakeFromInsert
{
	if([_environment extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    [super awakeFromInsert];
    [[self environment] assertObject: self];    
}

- (BOOL)validateForDelete:(NSError **)error
{
	if([_environment extraLogging])NSLog(@"%@ %@ entry",[self className],NSStringFromSelector( _cmd ));
    if([super validateForDelete: error])
    {
        [[self environment] retractObject: self];
        return YES;
    }
    return NO;
}

- (BOOL)validateForInsert:(NSError **)error
{
    return [super validateForInsert: error];
}

- (BOOL)validateForUpdate:(NSError **)error
{
    return [super validateForUpdate: error];
}

@end

