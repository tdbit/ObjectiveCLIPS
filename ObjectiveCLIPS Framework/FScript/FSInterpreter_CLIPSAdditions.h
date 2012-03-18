//
//  FSInterpreter_CLIPSAdditions.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Tue Oct 01 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FScript/FScript.h>
@class KBEnvironment;

@interface FSInterpreter (CLIPSAdditions)

-(void)_attachToEnvironment:(KBEnvironment*) env;

@end
