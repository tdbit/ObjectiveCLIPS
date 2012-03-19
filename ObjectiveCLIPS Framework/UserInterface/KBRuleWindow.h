//
//  KBRuleWindow.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 1/30/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KBEnvironment;
@interface KBRuleWindow : NSWindow 
{
    IBOutlet id rulesController;
    IBOutlet id inputTextArea;
    IBOutlet id outputTextArea;
    
    IBOutlet KBEnvironment *environment;

    BOOL shouldSubmit;
}

- (id)currentRule;
- (IBAction)performCommand:(id)sender;


@end
