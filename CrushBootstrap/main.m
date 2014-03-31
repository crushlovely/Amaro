//
//  main.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#ifdef COCOAPODS_POD_AVAILABLE_PixateFreestyle
#import <PixateFreestyle/PixateFreestyle.h>
#endif

#import <UIKit/UIKit.h>
#import "CRBSAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {

#ifdef COCOAPODS_POD_AVAILABLE_PixateFreestyle
        [PixateFreestyle initializePixateFreestyle];
#endif

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CRBSAppDelegate class]));
    }
}
