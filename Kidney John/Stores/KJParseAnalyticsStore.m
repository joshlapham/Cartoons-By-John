//
//  KJParseAnalyticsStore.m
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJParseAnalyticsStore.h"
#import "KJVideo.h"
#import "KJComic.h"
#import "KJRandomImage.h"
#import <Parse/Parse.h>

// Constants
// Parse Analytics keys
// Videos
static NSString * kParseAnalyticsKeyEventName = @"videoFavourite";
static NSString * kParseAnalyticsKeyVideoTitle = @"videoTitle";
static NSString * kParseAnalyticsKeyVideoId = @"videoId";
static NSString * kParseAnalyticsKeyVideoIsFavourite = @"isFavourite";

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

#pragma mark - Videos

+ (void)sendVideoFavouriteEventForVideo:(KJVideo *)video {
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyVideoTitle : video.videoName,
                                 kParseAnalyticsKeyVideoId : video.videoId,
                                 kParseAnalyticsKeyVideoIsFavourite : video.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyEventName
                 dimensions:dimensions];
}

@end
