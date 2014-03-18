//
//  main.m
//  CrushBootstrap
//
//  Created by Tim Clem on 3/2/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import <PixateFreestyle/PixateFreestyle.h>
#import <UIKit/UIKit.h>

#import "CRBSAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CRBSAppDelegate class]));
    }
}
