//
//  CRBSAppDelegate.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRBSAppDelegate.h"

#ifdef COCOAPODS_POD_AVAILABLE_CrashlyticsFramework
#import <Crashlytics/Crashlytics.h>
#endif

#ifdef COCOAPODS_POD_AVAILABLE_CocoaLumberjack
    #import <CocoaLumberjack/DDASLLogger.h>
    #import <CocoaLumberjack/DDTTYLogger.h>

    #ifdef COCOAPODS_POD_AVAILABLE_CrashlyticsLumberjack
    #import <CrashlyticsLumberjack/CrashlyticsLogger.h>
    #endif

    #ifdef COCOAPODS_POD_AVAILABLE_CRLLib
    #import <CRLLib/CRLMethodLogFormatter.h>
    #endif
#endif


@implementation CRBSAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeLoggingAndServices];
    [self applyBuildIconBadge];

    return YES;
}

-(void)initializeLoggingAndServices
{
#ifdef COCOAPODS_POD_AVAILABLE_CrashlyticsFramework
    [Crashlytics startWithAPIKey:@"c8472ec808f54475648e7963858199db751e8608"];
#endif

#if defined(COCOAPODS_POD_AVAILABLE_CRLInstallrChecker) && defined(CONFIGURATION_ADHOC)
    // Uncomment and fill in your Installr app key to automatically prompt the user about app updates.
    /*
     [CRLInstallrChecker sharedInstance].appKey = @"<installr app key>";
     dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
     
     // Waiting for 3 seconds in hopes that the app will be fully usable by then.
     // Feel free to adjust the delay as needed, or even move the -checkNow call to your main VC.
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), lowPriorityQueue, ^{
         [[CRLInstallrChecker sharedInstance] checkNow]];
     });
     */
#endif

#ifdef COCOAPODS_POD_AVAILABLE_CocoaLumberjack
    #ifdef COCOAPODS_POD_AVAILABLE_CRLLib
    CRLMethodLogFormatter *logFormatter = [[CRLMethodLogFormatter alloc] init];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
    #endif

    // Emulate NSLog behavior for DDLog*
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    // Send warning & error messages to Crashlytics
    #ifdef COCOAPODS_POD_AVAILABLE_CrashlyticsLumberjack
    [[CrashlyticsLogger sharedInstance] setLogFormatter:logFormatter];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance] withLogLevel:LOG_LEVEL_INFO];
    #endif
#endif
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
