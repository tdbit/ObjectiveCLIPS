//
//  KBAgendaWindow.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/8/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBAgendaWindow.h"
#import "KBEnvironment.h"

@implementation KBAgendaWindow

- (IBAction)fireRule:(id)sender
{
    [environment runWithLimit: 1];
}

@end
