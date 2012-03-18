#import "KBUserInterface.h"

@implementation KBUserInterface

- (void) awakeFromNib
{
    id mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSArray* items = [mainMenu itemArray];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity: [items count]];
    int i, count = [items count];
    for(i = 0; i < count; ++i)
    {
        [array addObject: [[items objectAtIndex: i] title]];
    } 
    i = [array indexOfObject: @"Help"];
    if(i > -1)
    {
        NSMenuItem* toolsItem = [[NSMenuItem alloc]initWithTitle:@"Tools" action:nil keyEquivalent:@""];
        [toolsMenu setTitle: @"Tools"];
        [toolsItem setSubmenu: toolsMenu];
        [mainMenu insertItem: toolsItem atIndex: i];
        [toolsItem setTitle: @"Tools"];
    }
}


-(void) environmentDidChange:(id) env
{
    
}

@end
