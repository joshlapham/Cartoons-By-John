//
//  KJBaseTableViewCell.m
//  Kidney John
//
//  Created by Josh Lapham on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJBaseTableViewCell.h"

@implementation KJBaseTableViewCell

#pragma mark - Cell reuse identifer method

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Configure cell with data method

- (void)configureCellWithData:(id)data {
    NSAssert(data, @"Must be called in a subclass only");
}

@end
