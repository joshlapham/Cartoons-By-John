//
//  KJParseAnalyticsStore.h
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KJVideo, KJComic, KJRandomImage;

@interface KJParseAnalyticsStore : NSObject

// Methods
// Init
+ (KJParseAnalyticsStore *)sharedStore;

// Favourited item event methods
- (void)trackVideoFavouriteEventForVideo:(KJVideo *)video;
- (void)trackComicFavouriteEventForComic:(KJComic *)comic;
- (void)trackDoodleFavouriteEventForDoodle:(KJRandomImage *)doodle;

// Shared item event methods
- (void)trackVideoShareEventForVideo:(KJVideo *)video;
- (void)trackComicShareEventForComic:(KJComic *)comic;
- (void)trackDoodleShareEventForDoodle:(KJRandomImage *)doodle;

// Played video event method
- (void)trackVideoPlayEventForVideo:(KJVideo *)video;

// Viewed comic event method
- (void)trackComicViewEventForComic:(KJComic *)comic;

@end
