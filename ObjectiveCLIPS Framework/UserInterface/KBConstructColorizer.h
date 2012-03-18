//
//  KBConstructColorizer.h
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 2/22/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KBConstructColorizer : NSObject 
{
    int idxLeft;
    int idxRight;
    int pCount;
    int bCount;
    NSString* string;
    NSMutableAttributedString* attributedString;
}

+ colorizer;
+(NSDictionary*)defaultAttributes;

-(NSAttributedString*)colorizeString:(id)s;
-(NSAttributedString*)recolorizeString:(NSMutableAttributedString*)s;

- (void)scanConstructName;
- (void)scanComment;
@end
