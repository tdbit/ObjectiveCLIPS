//
//  KBRouter.h
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on Sat Sep 28 2002.
//  Copyright (c) 2002 Todd Blanchard. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KBEnvironment;

@interface KBRouter : NSObject 
{
    KBEnvironment*		_environment;
    BOOL				_active;
    NSMutableArray*		_aliases;
    NSString*			_name;
    int					_priority;			
    id					_delegate;
}
-initWithEnvironment:(KBEnvironment*)env name:(NSString*) name priority:(int) p;
-initWithEnvironment:(KBEnvironment*)env name:(NSString*) name;

-(int)priority;

-(NSString*)name;
-(BOOL)answersToName:(NSString*)name;
-(void)addAlias:(NSString*)alias;
-(NSArray*)aliasList;

-(BOOL)active;
-(void)activate;
-(void)deactivate;

-(void)setDelegate:(id)delegate;
-(id)delegate;

@end

@interface KBRouter (KBRouterDelegation)

-(void)appendString:(NSString*)str;
-(int)readChar;
-(void)unReadChar:(int)c;

@end
