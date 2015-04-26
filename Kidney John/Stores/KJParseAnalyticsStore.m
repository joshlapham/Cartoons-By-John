//
//  KJParseAnalyticsStore.m
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJParseAnalyticsStore.h"

@implementation KJParseAnalyticsStore

#pragma mark - Init method

+ (KJParseAnalyticsStore *)sharedStore {
    static KJParseAnalyticsStore *_sharedStore = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJParseAnalyticsStore alloc] init];
    });
    
    return _sharedStore;
}

@end
