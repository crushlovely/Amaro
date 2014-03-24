//
//  CRBSAppDelegate.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRBSAppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>
#import <CRLLib/CRLMethodLogFormatter.h>


@implementation CRBSAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeLogging];
    [self applyBuildIconBadge];

    return YES;
}

-(void)initializeLogging
{
    [Crashlytics startWithAPIKey:@"c8472ec808f54475648e7963858199db751e8608"];

    CRLMethodLogFormatter *logFormatter = [[CRLMethodLogFormatter alloc] init];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];

    // Emulate NSLog behavior for DDLog*
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Send warning & error messages to Crashlytics
    [[CrashlyticsLogger sharedInstance] setLogFormatter:logFormatter];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance] withLogLevel:LOG_LEVEL_INFO];
}


/**
 Use a private API to badge the application icon with an alpha or beta for internal/ad hoc builds.
 */
-(void)applyBuildIconBadge
{
#if defined(CONFIGURATION_DEBUG) || defined(CONFIGURATION_ADHOC)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setApplicationBadgeString:)]) {
        #ifdef CONFIGURATION_DEBUG
        NSString *badgeString = @"α";
        #else
        NSString *badgeString = @"β";
        #endif

        [[UIApplication sharedApplication] performSelector:@selector(setApplicationBadgeString:) withObject:badgeString];
    }
#pragma clang diagnostic pop

#endif
}

@end
