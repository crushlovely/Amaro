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

@end
