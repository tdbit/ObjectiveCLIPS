//
//  KBUserInterface.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//
#import <Cocoa/Cocoa.h>
@class KBEnvironment;

@interface KBUserInterface : NSObject
{
    IBOutlet KBEnvironment *environment;
    IBOutlet NSMenu *toolsMenu;
    IBOutlet NSWindow *agendaWindow;
    IBOutlet NSWindow *consoleWindow;
    IBOutlet NSWindow *rulesWindow;
    IBOutlet NSWindow *templatesWindow;
    IBOutlet NSArrayController *templatesController;
}

-(void) awakeFromNib;

-(void) environmentDidChange:(id) env;

@end
