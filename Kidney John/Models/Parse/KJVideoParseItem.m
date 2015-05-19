//
//  KJVideoParseItem.m
//  Kidney John
//
//  Created by Josh Lapham on 19/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoParseItem.h"

@implementation KJVideoParseItem

// TODO: BOOL for is_active
@dynamic videoId, videoName, videoDescription, videoDuration;

// Parse helper methods
+ (NSString *)parseClassName {
    return @"Video";
}

@end
