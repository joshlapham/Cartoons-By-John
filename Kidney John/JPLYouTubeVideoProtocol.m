//
//  JPLYouTubeVideoProtocol.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "JPLYouTubeVideoProtocol.h"

@implementation JPLYouTubeVideoProtocol

@synthesize videosArray;

- (void)updateVideosArrayWithVideo:(KJVideo *)video
{
    [videosArray addObject:video];
    NSLog(@"DELEGATE: update videosArray with video: %@, array count is: %lu", video, (unsigned long)videosArray.count);
}

@end
