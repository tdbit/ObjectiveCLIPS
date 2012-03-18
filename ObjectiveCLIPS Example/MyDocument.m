//  MyDocument.m
//  ObjectiveCLIPSExample
//
//  Created by Todd  Blanchard on 8/2/05.
//  Copyright Black Bag Operations Network 2005 . All rights reserved.

#import "MyDocument.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil) {
        // initialization code
    }
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
    // user interface preparation code
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_context) 
    {
        // we use the KBManagedObjectContext subclass
        _context = [KBManagedObjectContext new];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [_context setPersistentStoreCoordinator:psc];
        [psc release];
        
        // get the CLIPS environment associated with the context
        KBEnvironment* env = [_context environment];

        // Load up the debugging tools menu
        // TODO: turn this off for production using a NSDefaults flag
        [env loadDeveloperTools];
        
        // see where the output goes
        //[env performCommand: @"(watch all)"];
        
        // set the template delegate to be the managed object context to enable auto-mapping of entities to facts
        // if you want to do something more clever, write your own delegate or simply preload a file with all your
        // template definitions and don't use the delegate at all.
        [env setTemplateDelegate: _context];
        
        // if you want to generate deftemplates from the model call this
        [_context defineTemplatesFromModel];

        // get a path to our rules file
        NSString* ruleFilePath = [[NSBundle mainBundle] pathForResource:@"Rules" ofType:@"clp"];
        
        // tell the environment to load it
        [env loadFile: ruleFilePath];
        
        //create the one TaxRate object
        [NSEntityDescription insertNewObjectForEntityForName: @"TaxRate" inManagedObjectContext: _context];

        //create a bill of sale object
        [NSEntityDescription insertNewObjectForEntityForName: @"BillOfSale" inManagedObjectContext: _context];
        
        
        //and we're off!
    }
    return _context;
}


@end
