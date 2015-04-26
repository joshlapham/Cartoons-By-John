//
//  KJParseAnalyticsStore.h
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KJVideo;

@interface KJParseAnalyticsStore : NSObject

// Methods
// Init
+ (KJParseAnalyticsStore *)sharedStore;

// Favourited item event methods
+ (void)sendVideoFavouriteEventForVideo:(KJVideo *)video;

@end
