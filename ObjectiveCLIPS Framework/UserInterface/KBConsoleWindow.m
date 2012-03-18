#import "KBConsoleWindow.h"
#import "KBEnvironment.h"
#import "KBRouter.h"
#import "KBConstructColorizer.h"

@implementation KBConsoleWindow

- (IBAction)clearHistory:(id)sender
{
    [outputTextArea setString: @""];
}

- (IBAction)flipAutoRun:(id)sender
{
    autoRun = [sender intValue];
    [environment setAutoRun: autoRun];
}

- (IBAction)performCommand:(id)sender
{
    NSString* command = [inputTextArea string];
    if([environment couldPerformCommand: command])
    {
        NSAttributedString *attributedString = [[KBConstructColorizer colorizer] colorizeString:command];
        [outputTextArea appendString: @"\nCLIPS> "];
        [outputTextArea appendString: attributedString];
//        [outputTextArea appendString: @"\n"];
        [environment performCommand: command];
        [inputTextArea setString: @""];
        if(autoRun)
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
    // change all output to route to us.
    KBRouter* scratch = [environment routerForName: @"scratch"];
    NSArray* names = [scratch aliasList];
    
    int i, count = [names count];
    for(i = 0; i < count; ++i)
    {
        NSString* name = [names objectAtIndex:i];
        KBRouter* router = [[KBRouter alloc] initWithEnvironment:environment name:name];
        [router setDelegate: outputTextArea];
        [router activate];
    }
    
    [inputTextArea setDelegate: self];
    [inputTextArea setFont:[NSFont userFixedPitchFontOfSize:0]];
    [[outputTextArea textStorage] setFont:[NSFont userFixedPitchFontOfSize:0]];
    autoRun = [environment autoRun];
    [autoRunCheckbox setObjectValue: [NSNumber numberWithBool: (BOOL) autoRun]];

	NSLog(@"%@ %@ entry, Debugging ON",[self className],NSStringFromSelector( _cmd ));
}

-(void)textDidChange:(NSNotification *)notification
{
    if(shouldSubmit) 
    {   
        shouldSubmit = NO;
        [self performCommand: nil];
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

@end


@interface NSText (KBRouterDelegate)

-(void)appendString:(NSString*)str;

@end


@implementation NSText (KBRouterDelegate)

-(void)appendString:(NSString*)str
{
/*
    NSRange range = { [[self string]length],0};
    [self replaceCharactersInRange:range withString:str];
    range.location += [str length];
    [self scrollRangeToVisible:range];
*/    
    
//    NSAttributedString *attributedString = [[KBConstructColorizer colorizer] colorizeString:str];
//	[[self textStorage] appendAttributedString:attributedString];

    if ([str isKindOfClass:[NSAttributedString class]]) {
        [[self textStorage] appendAttributedString:str];
    } else {
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str 
                                                                               attributes:[KBConstructColorizer defaultAttributes]];
    
        [[self textStorage] appendAttributedString:attributedString];
        [attributedString release];
     }
	[self scrollRangeToVisible:NSMakeRange( [[self string] length], 0 )]; 

}

@end
