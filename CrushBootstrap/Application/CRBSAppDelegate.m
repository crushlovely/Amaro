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
    #if COCOAPODS_VERSION_MAJOR_CocoaLumberjack == 1
    #import <CocoaLumberjack/DDASLLogger.h>
    #import <CocoaLumberjack/DDTTYLogger.h>
    #endif

    #if HAS_POD(CrashlyticsLumberjack)
    #import <CrashlyticsLumberjack/CrashlyticsLogger.h>
    #endif

    #if HAS_POD(Sidecar)
    #import <Sidecar/CRLMethodLogFormatter.h>
    #endif
#endif

#if HAS_POD(Aperitif) && IS_ADHOC_BUILD
#import <Aperitif/CRLAperitif.h>
#endif


@implementation CRBSAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeLoggingAndServices];

    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [self scheduleCheckForUpdates];
}


#pragma mark Amaro foundation goodies

/**
 Connects to Crashlytics and sets up CocoaLumberjack
 */
-(void)initializeLoggingAndServices
{
    #if HAS_POD(CrashlyticsFramework)
    NSString *crashlyticsAPIKey = @"((CrashlyticsAPIKey))";

    if([crashlyticsAPIKey characterAtIndex:0] != '(') [Crashlytics startWithAPIKey:crashlyticsAPIKey];
    else NSLog(@"Set your Crashlytics API key in the app delegate to enable Crashlytics integration!");
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
 Schedules a check for updates to the app in the Installr API. Only executed for Ad Hoc builds,
 not targetting the simulator (i.e. archives of the -Staging and -Production schemes).
 */
-(void)scheduleCheckForUpdates
{
    // Uncomment the blob below and fill in your Installr app tokens to enable automatically
    // prompting the user when a new build of your app is pushed.

    #if HAS_POD(Aperitif) && IS_ADHOC_BUILD && !TARGET_IPHONE_SIMULATOR && !defined(DEBUG)

//    #ifdef TARGETING_STAGING
//    NSString * const installrAppToken = @"<Installr app token for the staging build of your app>";
//    #else
//    NSString * const installrAppToken = @"<Installr app token for the production build of your app>";
//    #endif
//
//    [CRLAperitif sharedInstance].appToken = installrAppToken;
//    [[CRLAperitif sharedInstance] checkAfterDelay:3.0];

    #endif
}

@end
