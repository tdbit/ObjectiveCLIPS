/*
 *  KBBlock.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd  Blanchard on 3/2/06.
 *  Copyright 2006 Black Bag Operations Network. All rights reserved.
 *
 */
 
#import <Foundation/Foundation.h>

@class KBEnvironment;
@class Block;

/* An FScript Block with argument type info */ 
@interface KBBlock : NSObject
{
    KBEnvironment*          _environment;
    Block*                  _block;
    NSMutableDictionary*    _argTypes;
    NSString*               _src;
}

+blockWithSrcData:(NSData*)data environment:(KBEnvironment*)env;
-initWithSrcData:(NSData*)data environment:(KBEnvironment*)env;

-(KBEnvironment*)environment;

-(Block*)block;

-(NSArray*)argumentNames;
-(int)argumentCount;

// private methods used in initialization
-(NSData*)_scanVariables:(NSData*)data;
-(Block*)_compileBlock:(NSData*)data;
-(void)_bindCLIPSArguments:(void*)top;
-(void)_addArgumentNamed: (NSString*) str type: (unsigned short)t;

@end
