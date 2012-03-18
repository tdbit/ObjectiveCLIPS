//  MyDocument.h
//  ObjectiveCLIPSExample
//
//  Created by Todd  Blanchard on 8/2/05.
//  Copyright Black Bag Operations Network 2005 . All rights reserved.

#import <Cocoa/Cocoa.h>
#include <ObjectiveCLIPS/KBManagedObjectContext.h>

@class KBManagedObjectContext, KBEnvironment;

@interface MyDocument : NSPersistentDocument {
    KBManagedObjectContext* _context;
}

@end
