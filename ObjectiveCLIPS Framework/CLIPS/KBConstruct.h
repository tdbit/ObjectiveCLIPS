/*
 *  KBConstruct.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd  Blanchard on 2/24/06.
 *  Copyright 2006 Black Bag Operations Network. All rights reserved.
 *
 */

#include <ObjectiveCLIPS/KBNamedObject.h>

@class KBEnvironment;

@interface KBConstruct : KBNamedObject
{
    NSAttributedString* _attributedDescription;
}

+(void)hookConstructInEnvironment:(KBEnvironment*) env;
+(void)unhookConstructInEnvironment:(KBEnvironment*) env;

-(NSAttributedString*)attributedDescription; 

@end

typedef int (*clipsParseConstructFunction)(void *env, char *logicalName);
typedef int (*clipsUndefConstructFunction)(void *theEnv, void* impl);



