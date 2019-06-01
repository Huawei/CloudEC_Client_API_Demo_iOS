//
//  NSDate+LocalString.m
//  eSpaceUI
//
//  Created by yemingxing on 3/13/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "NSDate+LocalString.h"
#import "ESpaceLocalDataManager.h"

#define ONE_DAY 24 * 60 * 60

#define ONE_MINITE 60
#define ONE_HOUR 60 * 60
#define TWO_DAY 2 * 60 * 60
#define TWO_DAYS 2 * ONE_DAY  

@implementation NSDate (LocalString)

- (NSString*) toLocalString {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:self];
    NSDateComponents* today = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:[NSDate date]];
    if (today.year ==component.year
        && today.month == component.month
        && today.day == component.day) {
        return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)component.hour, (long)component.minute];
    }
    if (ABS([self timeIntervalSinceDate:[[NSDate date] datePart]]) < ONE_DAY) {
        return [NSString stringWithFormat:@"%@ %.2ld:%.2ld", ECSLocalizedString(@"yesterday", nil), (long)component.hour, (long)component.minute];
    }
    return [NSString stringWithFormat:@"%ld/%.2ld/%.2ld %.2ld:%.2ld", (long)component.year, (long)component.month, (long)component.day, (long)component.hour, (long)component.minute];
}

- (NSString*) toTimeString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init] ;
    [format setTimeZone:[NSTimeZone localTimeZone]];
    [format setDateFormat:@"HH:mm"];
    NSString *time = [format stringFromDate:self];
    return time;
}

- (NSString*) tolocalDateString {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:self];
    NSDateComponents* today = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:[NSDate date]];
    if (today.year ==component.year
        && today.month == component.month
        && today.day == component.day) {
        return ECSLocalizedString(@"today", nil);
    }
    if (ABS([self timeIntervalSinceDate:[[NSDate date] datePart]]) < ONE_DAY) {
        return ECSLocalizedString(@"yesterday", nil);
    }
    if (today.year == component.year) {
        return [NSString stringWithFormat:@"%.2ld/%.2ld", (long)component.month, (long)component.day];
    }
    return [NSString stringWithFormat:@"%ld/%.2ld/%.2ld", (long)component.year, (long)component.month, (long)component.day];
}

- (NSString*) tolocalDateWithTimeString {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:self];
    NSDateComponents* today = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:[NSDate date]];
    if (today.year ==component.year
        && today.month == component.month
        && today.day == component.day) {
        return [NSString stringWithFormat:@"%@ %.2ld:%.2ld",ECSLocalizedString(@"today", nil), (long)component.hour, (long)                component.minute];
    }
    if (ABS([self timeIntervalSinceDate:[[NSDate date] datePart]]) < ONE_DAY) {
        return [NSString stringWithFormat:@"%@ %.2ld:%.2ld",ECSLocalizedString(@"yesterday", nil), (long)component.hour, (long)component.minute];
    }
    if (ABS([self timeIntervalSinceDate:[[NSDate date] datePart]]) < TWO_DAYS) {
        return [NSString stringWithFormat:@"%@ %.2ld:%.2ld",ECSLocalizedString(@"the_day_before_yesterday", nil), (long)component.hour, (long)component.minute];
    }
    if (today.year == component.year) {
        return [NSString stringWithFormat:@"%.2ld/%.2ld", (long)component.month, (long)component.day];
    }
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)component.year, (long)component.month, (long)component.day];
}

- (BOOL)isYesterday {
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:ONE_DAY * -1];
    NSString *yesterdayString = [[yesterday description] substringToIndex:10];
    NSString *selfString = [[self description] substringToIndex:10];
    return [selfString isEqualToString:yesterdayString] ? YES : NO;
}

- (BOOL)isToday {
    NSDate *today = [NSDate date];
    NSString *todayString = [[today description] substringToIndex:10];
    NSString *selfString = [[self description] substringToIndex:10];
    return [selfString isEqualToString:todayString] ? YES : NO;
}

- (NSString*) toNumberString {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | kCFCalendarUnitSecond fromDate:self];

    return [NSString stringWithFormat:@"%ld%.2ld%.2ld%.2ld%.2ld%.2ld", (long)component.year, (long)component.month, (long)component.day, (long)component.hour, (long)component.minute, (long)component.second];
}

- (NSDate*) datePart {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    return [calendar dateFromComponents:component];
}

- (NSDate*) dateWithNoSeconds {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents* component = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self];
    return [calendar dateFromComponents:component];
}

- (NSString *) toTopicViewCellTime {
    NSTimeInterval timeInterval = [self timeIntervalSinceDate:[NSDate date]] * -1;
    
    if (timeInterval > 0 && timeInterval < ONE_MINITE) {
        return [NSString stringWithFormat:ECSLocalizedString(@"mins_before", nil), 1];
    }
    
    if (timeInterval > 0 && timeInterval > ONE_MINITE && timeInterval < ONE_HOUR) {
        return [NSString stringWithFormat:ECSLocalizedString(@"mins_before", nil), (long)(timeInterval / 60.0f)];
    }
    
    if (timeInterval > 0 && timeInterval > ONE_HOUR && timeInterval < ONE_DAY) {
        return [NSString stringWithFormat:ECSLocalizedString(@"hours_before", nil), (long)(timeInterval / 60.0f / 60.0f)];
    }
    
    if (timeInterval > 0 && timeInterval > ONE_DAY && timeInterval < TWO_DAY) {
        return ECSLocalizedString(@"yesterday", nil);
    }
    
    if (timeInterval > 0 && timeInterval > TWO_DAY) {
        return [NSString stringWithFormat:ECSLocalizedString(@"days_before", nil), (long)(timeInterval / 60.0f / 60.f / 24.0f)];
    }
    
    return @"";
}
@end
