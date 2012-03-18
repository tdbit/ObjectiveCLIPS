/*
 *  KBDate.h
 *  ObjectiveCLIPS
 *
 *  Created by Todd Blanchard on 6/28/05.
 *  Copyright 2005 Todd Blanchard. All rights reserved.
 *
 */

#include <Foundation/Foundation.h>

@interface NSDate (KBDate)

-(NSDate*)dateByAddingDays:(int)days;
-(NSDate*)dateByAddingWeekdays:(int)days;

-(int)daysUntil:(NSDate*)date;
-(int)weekdaysUntil:(NSDate*)date;

-(int)daysSince:(NSDate*)date;
-(int)weekdaysSince:(NSDate*)date;

-(NSDate*)nextDay;
-(NSDate*)previousDay;

-(BOOL)isWeekday;
-(BOOL)isWeekend;

-(NSCalendarDate*)asCalendarDate;

-(NSDate*)midnight;
-(NSDate*)noon;



@end

@interface NSCalendarDate (KBDate)

-(NSCalendarDate*)asCalendarDate;


@end
