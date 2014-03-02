//
//  CRLMethodLogFormatter.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRLMethodLogFormatter.h"

NS_INLINE const char *CRLLogFlagToCString(int logFlag)
{
    switch(logFlag) {
        case LOG_FLAG_ERROR: return "ERR";
        case LOG_FLAG_WARN: return "WRN";
        case LOG_FLAG_INFO: return "INF";
        case LOG_FLAG_DEBUG: return "DBG";
        case LOG_FLAG_VERBOSE: return "VRB";

        default: return "";
    }
}


@interface CRLMethodLogFormatter () {
    NSCalendar *calendar;
    NSUInteger calendarUnitFlags;
}

@end


@implementation CRLMethodLogFormatter

-(id)init
{
    if ((self = [super init]))
    {
        calendar = [NSCalendar autoupdatingCurrentCalendar];

        calendarUnitFlags = 0;
        calendarUnitFlags |= NSYearCalendarUnit;
        calendarUnitFlags |= NSMonthCalendarUnit;
        calendarUnitFlags |= NSDayCalendarUnit;
        calendarUnitFlags |= NSHourCalendarUnit;
        calendarUnitFlags |= NSMinuteCalendarUnit;
        calendarUnitFlags |= NSSecondCalendarUnit;
    }

    return self;
}

-(NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    // Time calculation is ripped from DDTTYLogger

    NSDateComponents *components = [calendar components:calendarUnitFlags fromDate:logMessage->timestamp];

    NSTimeInterval epoch = [logMessage->timestamp timeIntervalSinceReferenceDate];
    int milliseconds = (int)((epoch - floor(epoch)) * 1000);

    const char *function = logMessage->function;

    NSString *formattedMsg = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld:%03d %s%@ [%s] %@",
                              (long)components.year,
                              (long)components.month,
                              (long)components.day,
                              (long)components.hour,
                              (long)components.minute,
                              (long)components.second, milliseconds,
                              function ? function : "",                // Include either the function name, or if we don't have that ...
                              function ? @"" : logMessage.fileName,    // .. the filename
                              CRLLogFlagToCString(logMessage->logFlag),
                              logMessage->logMsg];

    return formattedMsg;
}

@end
