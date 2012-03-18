//
//  KBRouter.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 28 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import "KBRouter.h"
#import "KBEnvironment.h"
#import <CLIPS/clips.h>


/*************************************************************/
/* FindString: Find routine for string router logical names. */
/*************************************************************/
static int FindKBRouter(void *theEnv, char *logicalName)
{    
    return [[KBEnvironment environmentForImplementation: theEnv] activeRouterForName: [NSString stringWithUTF8String: logicalName]] != nil;
}

/**************************************************/
/* PrintString: Print routine for string routers. */
/**************************************************/
static int PrintOnKBRouter(void *theEnv, char *logicalName, char *str)
{
    KBRouter* router = [[KBEnvironment environmentForImplementation: theEnv] activeRouterForName: [NSString stringWithUTF8String: logicalName]];
    
    [router appendString:[NSString stringWithUTF8String:str]];
   return(1);
}

/************************************************/
/* GetcString: Getc routine for string routers. */
/************************************************/
static int KBGetcString(
  void *theEnv,
  char *logicalName)
{
    KBRouter* router = [[KBEnvironment environmentForImplementation: theEnv] activeRouterForName: [NSString stringWithUTF8String: logicalName]];

    return [router readChar];
}
/****************************************************/
/* UngetcString: Ungetc routine for string routers. */
/****************************************************/
static int KBUngetcString(
  void *theEnv,
  int ch,
  char *logicalName)
{
    KBRouter* router = [[KBEnvironment environmentForImplementation: theEnv] activeRouterForName: [NSString stringWithUTF8String: logicalName]];

    [router unReadChar: ch];

   return(1);
}
  
static int KBExitPrintRouter(void *theEnv, int num)
{
    return 1;
}

@implementation KBRouter

-initWithEnvironment:(KBEnvironment*)env name:(NSString*) name
{
    return [self initWithEnvironment:env name:name priority: 0];
}

-initWithEnvironment: (KBEnvironment*) env name:(NSString*) nm priority:(int) priority
{
    if(self = [super init])
    {
        _priority = priority;
        _name = [nm retain];
        _aliases = [NSMutableArray new];
        [_aliases addObject: nm];
        _environment = env;
                
        struct router *currentPtr = RouterData([env _impl])->ListOfRouters;

        /*==============================================*/
        /* Search through the list of routers until one */
        /* is found that will handle the print request. */
        /*==============================================*/

        while (currentPtr != NULL)
        {
            NSString* rName = [NSString stringWithUTF8String: currentPtr->name];
            if ([rName isEqualToString: nm])
            {
                break;
            }
            currentPtr = currentPtr->next;
        }
        
        if(currentPtr) // tweak the router methods to use our object
        {
            currentPtr->query   = FindKBRouter;
            currentPtr->printer = PrintOnKBRouter;
            currentPtr->exiter  = KBExitPrintRouter;
            currentPtr->charget = KBGetcString;
            currentPtr->charunget = KBUngetcString;
            currentPtr->environmentAware = YES;
        }
        else
        {
            EnvAddRouter([env _impl],(char*)[[self name] UTF8String],_priority,FindKBRouter,PrintOnKBRouter,KBGetcString,KBUngetcString,KBExitPrintRouter);
            [self deactivate];
        }
        [_environment addRouter: self];
        
    }
    return self;
}

-(void)dealloc
{
    [_name release];
    [_aliases release];
    [super dealloc];
}

-(int)priority
{
    return _priority;
}

-(NSString*)name 
{ 
    return _name; 
}

-(BOOL)answersToName:(NSString*) name
{
    return [_aliases containsObject: name];
}

-(void)addAlias:(NSString*) name
{
    [_aliases addObject: name];
}

-(NSArray*)aliasList
{
    return _aliases;
}

-(BOOL)active
{
    return _active;
}

-(void)activate
{ 
    EnvActivateRouter([_environment _impl],(char*)[_name UTF8String]);
    _active = YES;
}

-(void)deactivate
{
    EnvDeactivateRouter([_environment _impl],(char*)[_name UTF8String]);     
    _active = NO;
}

-(void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

-(id)delegate
{
    return _delegate;
}

-(void)appendString:(NSString*)str
{
    if([_delegate respondsToSelector:@selector(appendString:)])
    {
        [_delegate appendString: str];
    }
}

-(int)readChar
{
    if([_delegate respondsToSelector:@selector(readChar)])
    {
        return [_delegate readChar];
    }
    return 0;
}

-(void)unReadChar:(int)i
{
    if([_delegate respondsToSelector:@selector(readChar)])
    {
        [_delegate unReadChar: i];
    }
}

@end

@interface NSMutableString (KBRouterAdditions)

-(int)readChar;
-(void)unReadChar:(int)i;

@end

@implementation NSMutableString (KBRouterAdditions)

-(int)readChar
{
    int ch = [self characterAtIndex:0];
    [self deleteCharactersInRange: NSMakeRange(0,1)];
    return ch;
}

-(void)unReadChar:(int)i
{
    unichar ch = (unichar) i;
    [self insertString: [[[NSString alloc] initWithCharacters:&ch length:1] autorelease] atIndex: 0];
}

@end
