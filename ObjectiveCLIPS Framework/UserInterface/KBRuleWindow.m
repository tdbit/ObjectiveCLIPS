//
//  KBRuleWindow.m
//  ObjectiveCLIPS
//
//  Created by Todd  Blanchard on 1/30/06.
//  Copyright 2006 Black Bag Operations Network. All rights reserved.
//

#import "KBRuleWindow.h"
#import "KBEnvironment.h"

@implementation KBRuleWindow

- (IBAction)performCommand:(id)sender
{

    NSString* command = [inputTextArea string];
/*
    NSString* oldCommand = [[self currentRule] description];
    
    if([[command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString: [oldCommand stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) return;
*/    
    if([environment couldPerformCommand: command])
    {
        [environment performCommand: command];
        [inputTextArea setString: @""];
        if([environment autoRun])
        {
            if([environment runWithLimit: 100] == 100)
            {
                [inputTextArea setString: @"Run Limit Reached!"];
            }
        }
    }
}

-(void)awakeFromNib
{    
    [inputTextArea setDelegate: self];
    [[outputTextArea textStorage] setFont:[NSFont userFixedPitchFontOfSize:0]];
}

-(void)textDidChange:(NSNotification *)notification
{
    if(shouldSubmit) 
    {   
        shouldSubmit = NO;
        [self performCommand: nil];
    }
    else
    {
        NSString* command = [inputTextArea string];
        NSString* oldCommand = [[self currentRule] description];
    }
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSRange range = { [[textView string] length] };
    if(affectedCharRange.location == range.location && [replacementString isEqualToString: @"\n"])
    {
        shouldSubmit = YES;
    }
    return YES;
}

- (id)currentRule
{
    id rule = [[rulesController selectedObjects] lastObject];
    return rule;
}


@end
