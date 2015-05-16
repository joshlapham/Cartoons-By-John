//
//  KJBaseDataSource.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJBaseDataSource.h"

@implementation KJBaseDataSource

#pragma mark - Init method

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cellDataSource = [NSArray new];
    }
    
    return self;
}

@end
