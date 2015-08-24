//
//  CRBSConstants.m
//  CrushBootstrap
//
//  Created by Tim Clem on 9/8/14.
//  Copyright (c) 2014 Crush & Lovely. All rights reserved.
//

#import "CrushBootstrap-Environment.h"

// Use this file to define the values of the variables declared in the header.
// For data types that aren't compile-time constants (e.g. NSURL), use the
// CRBSConstantsInitializer function below.

// See CrushBootstrap-Environment.h for macros that are likely applicable in
// this file. TARGETING_{STAGING,PRODUCTION} and IF_STAGING are probably
// the most useful.

// The values here are just examples.

#ifdef TARGETING_STAGING

//NSString * const CRBSAPIKey = @"StagingKey";

#else

//NSString * const CRBSAPIKey = @"ProductionKey";

#endif


//NSURL *CRBSAPIRoot;
void __attribute__((constructor)) CRBSConstantsInitializer()
{
//    CRBSAPIRoot = [NSURL URLWithString:IF_STAGING(@"http://myapp.com/api/staging", @"http://myapp.com/api")];
}