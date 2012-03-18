//
//  KBString.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/14/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBString.h"


@implementation NSString (StringByRemovingCharactersInSet)

-(NSString *)stringByRemovingCharactersInSet: (NSCharacterSet *) set
{
    unsigned length = [self length];
    unichar buffer[256]; // attempt to avoid malloc for small strings -tb
    unichar *p = buffer;
    unichar *p1, *p2, *end;
    NSString *newString;

    if (length > 255)
    {
        p = malloc(sizeof(unichar)*(length+1));
    }
    [self getCharacters: p];
    end = p+length;
    p1 = p;
    while(p1 < end && ! [set characterIsMember: *p1]) ++p1;
    p2 = p1;
    while(p1 < end)
    {
        if(![set characterIsMember: *p1])
            *p2++ = *p1;
        ++p1;
    }
    newString = [NSString stringWithCharacters: p length: (p2-p)];
    if(p != buffer)
        free(p);
    return newString;
}

@end