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
static NSString * kParseAnalyticsKeyVideoEventName = @"videoFavourite";
static NSString * kParseAnalyticsKeyVideoPlayedEventName = @"videoPlayed";
static NSString * kParseAnalyticsKeyVideoTitle = @"videoTitle";
static NSString * kParseAnalyticsKeyVideoId = @"videoId";
static NSString * kParseAnalyticsKeyVideoIsFavourite = @"isFavourite";

// Comics
static NSString * kParseAnalyticsKeyComicEventName = @"comicFavourite";
static NSString * kParseAnalyticsKeyComicTitle = @"comicTitle";
static NSString * kParseAnalyticsKeyComicId = @"comicId";
static NSString * kParseAnalyticsKeyComicIsFavourite = @"isFavourite";

// Doodles
static NSString * kParseAnalyticsKeyDoodleEventName = @"doodleFavourite";
static NSString * kParseAnalyticsKeyDoodleUrl = @"doodleURL";
static NSString * kParseAnalyticsKeyDoodleId = @"doodleId";
static NSString * kParseAnalyticsKeyDoodleIsFavourite = @"isFavourite";

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

#pragma mark - Favourited item event methods

// Videos
- (void)trackVideoFavouriteEventForVideo:(KJVideo *)video {
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyVideoTitle : video.videoName,
                                 kParseAnalyticsKeyVideoId : video.videoId,
                                 kParseAnalyticsKeyVideoIsFavourite : video.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyVideoEventName
                 dimensions:dimensions];
}

// Comics
- (void)trackComicFavouriteEventForComic:(KJComic *)comic {
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyComicTitle : comic.comicName,
                                 kParseAnalyticsKeyComicId : comic.comicNumber,
                                 kParseAnalyticsKeyComicIsFavourite : comic.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyComicEventName
                 dimensions:dimensions];
}

// Doodles
- (void)trackDoodleFavouriteEventForDoodle:(KJRandomImage *)doodle {
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyDoodleUrl : doodle.imageUrl,
                                 kParseAnalyticsKeyDoodleId : doodle.imageId,
                                 kParseAnalyticsKeyDoodleIsFavourite : doodle.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyDoodleEventName
                 dimensions:dimensions];
}

#pragma mark - Shared item event methods

// TODO: implement these methods

- (void)trackVideoShareEventForVideo:(KJVideo *)video {
}

- (void)trackComicShareEventForComic:(KJComic *)comic {
}

- (void)trackDoodleShareEventForDoodle:(KJRandomImage *)doodle {
}

#pragma mark -  Played video event method

- (void)trackVideoPlayEventForVideo:(KJVideo *)video {
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyVideoTitle : video.videoName,
                                 kParseAnalyticsKeyVideoId : video.videoId,
                                 kParseAnalyticsKeyVideoIsFavourite : video.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyVideoPlayedEventName
                 dimensions:dimensions];
}

@end
