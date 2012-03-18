//
//  KBConsoleWindow.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@class KBEnvironment;

@interface KBConsoleWindow : NSWindow
{
    IBOutlet KBEnvironment *environment;

    IBOutlet NSText *inputTextArea;
    IBOutlet NSText *outputTextArea;
    IBOutlet NSButton *autoRunCheckbox;

    BOOL shouldSubmit;
    BOOL autoRun;
}
- (IBAction)clearHistory:(id)sender;
- (IBAction)performCommand:(id)sender;

- (IBAction)flipAutoRun:(id)sender;


@end
