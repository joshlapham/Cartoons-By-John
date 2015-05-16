//
//  KJAdminStore.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJAdminStore.h"

@implementation KJAdminStore

#pragma mark - Init method

+ (instancetype)sharedStore {
    static KJAdminStore *_sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStore = [[KJAdminStore alloc] init];
    });
    
    return _sharedStore;
}


@end
