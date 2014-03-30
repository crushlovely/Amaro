//
//  ZZZCodeCoverageFixForiOS7.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/30/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

// Read about this here:
// http://stackoverflow.com/questions/18394655/xcode5-code-coverage-from-cmd-line-for-ci-builds
// Essentially the iOS 7 simulator doesn't shut down the app in a way that lets gcov
// appropriately output its coverage data. Calling __gcov_flush at the end of the
// tests fixes that. We're jankily relying on the ZZZ prefix of this test to make
// us fall at the end.
// A more robust solution (should it be needed) comes from Apple themselves:
// https://developer.apple.com/library/ios/qa/qa1514/_index.html


#import <XCTest/XCTest.h>

extern void __gcov_flush();


@interface ZZZCodeCoverageFixForiOS7 : XCTestCase
@end


@implementation ZZZCodeCoverageFixForiOS7

-(void)testFixGCovGeneration
{
    __gcov_flush();
}

@end
