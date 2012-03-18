//
//  KBAgendaWindow.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KBAgendaWindow : NSWindow
{
    IBOutlet id activationList;
    IBOutlet id activationText;
    IBOutlet id ruleText;
    IBOutlet id environment;
}

- (IBAction)fireRule:(id)sender;

@end
