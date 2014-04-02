//
//  CRBSAppDelegate.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CRBSAppDelegate.h"

#if HAS_POD(CrashlyticsFramework)
#import <Crashlytics/Crashlytics.h>
#endif

#if HAS_POD(CocoaLumberjack)
    #import <CocoaLumberjack/DDASLLogger.h>
    #import <CocoaLumberjack/DDTTYLogger.h>

    #if HAS_POD(CrashlyticsLumberjack)
    #import <CrashlyticsLumberjack/CrashlyticsLogger.h>
    #endif

    #if HAS_POD(Sidecar)
    #import <Sidecar/CRLMethodLogFormatter.h>
    #endif
#endif

#if HAS_POD(CRLInstallrChecker) && IS_ADHOC_BUILD
#import <CRLInstallrChecker/CRLInstallrChecker.h>
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
    #if HAS_POD(CrashlyticsFramework)
    NSString *crashlyticsAPIKey = @"<<CrashlyticsAPIKey>>";

    if([crashlyticsAPIKey characterAtIndex:0] != '<') [Crashlytics startWithAPIKey:crashlyticsAPIKey];
    else NSLog(@"Set your Crashlytics API key in the app delegate to enable Crashlytics integration!");
    #endif

    #if HAS_POD(CRLInstallrChecker) && IS_ADHOC_BUILD && !TARGET_IPHONE_SIMULATOR && !defined(DEBUG)
    // Uncomment and fill in your Installr app key to automatically prompt the user about app updates.
    /*
    [CRLInstallrChecker sharedInstance].appKey = @"<installr app key>";

    // Waiting for 3 seconds before triggering the update check, in hopes that the app will be fully
    // usable by then. Feel free to adjust the delay as needed, or even move the -checkNow call to
    // your main VC.
    dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), lowPriorityQueue, ^{
        [[CRLInstallrChecker sharedInstance] checkNow];
    });
     */
    #endif

    #if HAS_POD(CocoaLumberjack)
        #if HAS_POD(Sidecar)
        CRLMethodLogFormatter *logFormatter = [[CRLMethodLogFormatter alloc] init];
        [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
        [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
        #endif

        // Emulate NSLog behavior for DDLog*
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];

        // Send warning & error messages to Crashlytics
        #if HAS_POD(CrashlyticsLumberjack)
            #if HAS_POD(Sidecar)
            [[CrashlyticsLogger sharedInstance] setLogFormatter:logFormatter];
            #endif

            [DDLog addLogger:[CrashlyticsLogger sharedInstance] withLogLevel:LOG_LEVEL_INFO];
       #endif
    #endif
}


/**
 Use a private API to badge the application icon with an alpha or beta for internal/ad hoc builds.
 */
-(void)applyBuildIconBadge
{
    #if IS_DEBUG_BUILD || IS_ADHOC_BUILD

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setApplicationBadgeString:)]) {
        #ifdef TARGETING_STAGING
        NSString *badgeString = @"🅢";
        #else
        NSString *badgeString = @"🅟";
        #endif

        [[UIApplication sharedApplication] performSelector:@selector(setApplicationBadgeString:) withObject:badgeString];
    }
    #pragma clang diagnostic pop

    #endif
}

@end
