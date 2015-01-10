//
//  JPLReachabilityManager.h
//  Kidney John
//
//  Created by jl on 7/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface JPLReachabilityManager : NSObject

@property (nonatomic, strong) Reachability *reachability;

// Shared manager
+ (JPLReachabilityManager *)sharedManager;

// Class methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
