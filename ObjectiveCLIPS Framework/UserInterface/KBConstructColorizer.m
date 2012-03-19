//
//  KBConstructColorizer.m
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 2/22/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import "KBConstructColorizer.h"

static NSArray* _parenColors;
static NSDictionary* _defaultAttributes;
static KBConstructColorizer *sharedColorizer = nil;

@implementation NSScanner (Silly)

-(NSString*)upTo:(NSString*)str
{
    NSString* scanned = nil;
    [self scanUpToString: str intoString: &scanned];
    return scanned;
}

-(NSRange)rangeOfNext:(NSString*)str
{
    NSRange range = {-1,0};
    [self upTo: str];
    if([self isAtEnd])
    {
        range.location = [self scanLocation];
        range.length = [str length];
    }
    return range;
}

@end


@implementation KBConstructColorizer

+colorizer
{
    @synchronized(self) {
        if (sharedColorizer == nil)
            sharedColorizer = [[self alloc] init];
    }
    return sharedColorizer;
}

+(NSDictionary*)defaultAttributes
{
    if(!_defaultAttributes)
    {
        _defaultAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSFont userFixedPitchFontOfSize:0], NSFontAttributeName,
                                nil];
    }
    return _defaultAttributes;
}

-(NSArray*)parenColors
{
    if(!_parenColors)
    {
        _parenColors = [[NSArray alloc]initWithObjects:
            [NSColor blackColor],
            [NSColor colorWithCalibratedRed:0.6 green:0.0 blue:0.6 alpha:1.0],
            [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.0 alpha:1.0],
            [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.0 alpha:1.0],
            [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:0.4 alpha:1.0],
            nil];
    }
    return _parenColors;
}

-(NSColor*)commentColor
{
    return [NSColor colorWithCalibratedRed:0.0 green:0.4 blue:0.0 alpha:1.0];
}

-(NSColor*)keyWordColor
{
    return [NSColor colorWithCalibratedRed:0.6 green:0.0 blue:0.2 alpha:1.0];
}

-(NSColor*)variableColor
{
    return [NSColor colorWithCalibratedRed:0.0 green:0.6 blue:0.6 alpha:1.0];
}

-(NSDictionary*)defaultAttributes
{

}

-(NSAttributedString*)colorizeString:(id)s
{
    if([s isKindOfClass: [NSMutableAttributedString class]])
    {
        return [self recolorizeString: (NSMutableAttributedString*) s];
    }
    else if([s isKindOfClass:[NSAttributedString class]])
    {
        return [self recolorizeString: [s mutableCopy]];  
    }
    else
    {
        return [self recolorizeString:[[[NSMutableAttributedString alloc]
                                            initWithString:s 
                                                attributes:[KBConstructColorizer defaultAttributes]] autorelease]];
    }
}

-(NSColor*)colorAt:(int)i
{
    return [[self parenColors] objectAtIndex: i % [[self parenColors] count]];
}

-(void)setColor:(NSColor*)color
{
    if (idxLeft < [string length] && idxRight < [string length]) {
    NSRange range = {idxLeft, idxRight-idxLeft};
    [attributedString addAttribute: NSForegroundColorAttributeName
        value: color
        range: range];    
    }
}

-(NSAttributedString*)recolorizeString:(NSMutableAttributedString*)s
{
    bCount = 0;
    pCount = 0;
    idxLeft = 0;
    idxRight = 0;
    
    attributedString = [[NSMutableAttributedString alloc] 
                            initWithString:[s string]
                                attributes:[KBConstructColorizer defaultAttributes]];
    string = [s string];
    int length = [string length];
    int c = 0;
    [attributedString beginEditing];
    while(idxRight < length)
    {
        switch(c = [string characterAtIndex: idxRight])
        {
            case '(' :
            case '[' :
            {
                idxLeft = idxRight++;
                [self setColor: [self colorAt: bCount + pCount]];
                                
                if(pCount == 0) // first time only
                {
                    [self scanConstructName];
                    [self scanComment];
                }
                bCount+= (c=='[');
                pCount+= (c=='(');
                break;
            }
            case ')' :
            case ']' :
            {
                idxLeft = idxRight++;
                bCount-= (c==']');
                pCount-= (c==')');
                [self setColor: [self colorAt: bCount + pCount]];

                break;
            }
            case ';' :
            {
                idxLeft = idxRight++;
                do
                {
                    c = [string characterAtIndex: idxRight];
                } while(c != '\n' && c != '\r');
                [self setColor: [self commentColor]];
                break;
            }
            case '?' :
            {
                idxLeft = idxRight;
                while (c < [string length] &&
                       c != '\n' &&
                       c != '\r' && 
                       c != ' ' &&
                       c != '\t' &&
                       c != '~' &&
                       c != ')' &&
                       c != '(' &&
                       c != '[' &&
                       c != ']' &&
                       c != '&' ) {
                    c = [string characterAtIndex: idxRight];
                    ++idxRight;
                }
                idxRight--;
                [self setColor:[self variableColor]];
    
                break;
            }
            default:
            {
                ++idxRight;
                break;
            }
        }
    }
    [attributedString endEditing];
    [s setAttributedString: attributedString];
    [attributedString autorelease];
    return s;
}

-(void)scanConstructName
{
    int c = 0;
    while(idxRight < [string length] && 
          [string characterAtIndex: idxRight] == ' ') ++idxRight;
    idxLeft = idxRight++;
    while(idxRight < [string length] && 
          (c=[string characterAtIndex: idxRight]) != ' ' &&
          c != '\n' && 
          c != '\r' && 
          c != '"' && 
          c != ';') ++idxRight;
    [self setColor: [self keyWordColor]];
}

-(void)scanComment
{
    int c = 0;
    while(idxRight < [string length] && 
          (c=[string characterAtIndex: idxRight]) != '"' && 
          c != '\n' && 
          c != '\r') ++idxRight;
    if(c != '"') return;
    idxLeft = idxRight++;
    while((c=[string characterAtIndex: idxRight]) != '"') ++idxRight;
    ++idxRight;
    [self setColor: [self commentColor]];
}

@end
