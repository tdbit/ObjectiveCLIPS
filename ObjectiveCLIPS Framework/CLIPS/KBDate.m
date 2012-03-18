//
//  KBDate.m
//  ObjectiveCLIPS
//
//  Created by Todd Blanchard on 6/28/05.
//  Copyright 2005 Todd Blanchard. All rights reserved.
//

#import "KBDate.h"

#define SECONDS_PER_DAY ((NSTimeInterval)(24*60*60))

@implementation NSDate (KBDate)

+(NSString*)nameOfDay:(int) day
{
    static NSArray* names = nil;
    
    if(!names) names = [[NSArray arrayWithObjects: 
        @"sunday",
        @"monday",
        @"tuesday",
        @"wednesday",
        @"thursday",
        @"friday",
        @"saturday",nil]retain];
        
    return [names objectAtIndex: (day%[names count])];
}

-(NSDate*)dateByAddingDays:(int)days
{
    return [((NSCalendarDate*)[self midnight]) dateByAddingYears:0 months:0 days:days hours:0 minutes:0 seconds:0];
}

-(NSDate*)dateByAddingWeekdays:(int)days
{
    int dow = [[self asCalendarDate] dayOfWeek];
    int weeksToAdd = days / 5;
    int oddDays = days % 5;
    int realDays = (7*weeksToAdd) + oddDays;
    if(dow + oddDays > 5) realDays += 2;
    if(dow == 0) realDays += 1;
    return [self dateByAddingDays: realDays];
}

-(int)daysUntil:(NSDate*)date
{
    return [date daysSince: self];
}

-(int)daysSince:(NSDate*)date
{
    return [[self midnight] timeIntervalSinceDate: [date midnight]]/SECONDS_PER_DAY;
}

-(int)weekdaysUntil:(NSDate*)date
{
    // TODO: should be able to do better but this is easy to code.
    if([[self midnight] timeIntervalSinceReferenceDate] > [[date midnight] timeIntervalSinceReferenceDate])
    {
        return -[date weekdaysSince: self];
    }
    int weekdays = 0;
    id tomorrow = [self midnight];
    id laterDate = [date midnight];
    
    while(![tomorrow isEqualToDate: laterDate])
    {
        if([tomorrow isWeekday]) weekdays += 1;
        tomorrow = [tomorrow nextDay];
    }
    return weekdays;
}

-(int)weekdaysSince:(NSDate*)date
{
    return [date weekdaysUntil: self];
}

-(NSString*)weekdayName
{
    return [NSDate nameOfDay: [[self asCalendarDate] dayOfWeek]];
}

-(NSDate*)nextDay
{
    return [self dateByAddingDays: 1];
}

-(NSDate*)previousDay
{
    return [self dateByAddingDays:-1];
}

-(NSDate*)nextWeekday
{
    NSDate* next = [self dateByAddingDays: 1];
    while([next isWeekend])
    {
        next = [next dateByAddingDays: 1];
    }
    return next;
}

-(NSDate*)previousWeekday
{
    NSDate* next = [self dateByAddingDays: -1];
    while([next isWeekend])
    {
        next = [next dateByAddingDays: -1];
    }
    return next;
}

-(BOOL)isWeekday
{
    int dow = [[self asCalendarDate] dayOfWeek];
    return (dow != 0 && dow != 6); 
}

-(BOOL)isWeekend
{
    return ![self isWeekday];
}


-(NSCalendarDate*)asCalendarDate
{
    return [NSCalendarDate dateWithTimeIntervalSinceReferenceDate: [self timeIntervalSinceReferenceDate]];
}

- (int)yearOfCommonEra
{
    return [[self asCalendarDate]yearOfCommonEra];
}

- (int)monthOfYear
{
    return [[self asCalendarDate]monthOfYear];
}

- (int)dayOfMonth
{
    return [[self asCalendarDate]dayOfMonth];
}

- (int)dayOfWeek
{
    return [[self asCalendarDate]dayOfWeek];
}

- (int)dayOfYear
{
    return [[self asCalendarDate]dayOfYear];
}

- (int)dayOfCommonEra
{
    return [[self asCalendarDate]dayOfCommonEra];
}

- (int)hourOfDay
{
    return [[self asCalendarDate]hourOfDay];
}

- (int)minuteOfHour
{
    return [[self asCalendarDate]minuteOfHour];
}

- (int)secondOfMinute
{
    return [[self asCalendarDate]secondOfMinute];
}

-(NSDate*)midnight
{
    id d = [self asCalendarDate];
    return [NSCalendarDate dateWithYear:[d yearOfCommonEra] month:[d monthOfYear] day:[d dayOfMonth] hour:0 minute:0 second:0 timeZone:nil];
}

-(NSDate*)noon
{
    return [((NSCalendarDate*)[self midnight]) dateByAddingYears:0 months:0 days:0 hours:12 minutes:0 seconds:0];
}

@end

@implementation NSCalendarDate (KBDate)

-(NSCalendarDate*)asCalendarDate
{
    return self;
}

@end
