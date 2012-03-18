//
//  FSDataObject.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Wed Oct 02 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <CLIPS/setup.h>
#import <CLIPS/constant.h>
#import <CLIPS/evaluatn.h>

#import <Foundation/Foundation.h>
#import <FScript/Number.h>
#import <FScript/FSBoolean.h>

@class KBEnvironment;

@interface Number (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;

@end

@interface False (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;

@end

@interface True (FSDataObject)

- (void) dataObject: (DATA_OBJECT*) obj inEnvironment: (KBEnvironment *) env;

@end