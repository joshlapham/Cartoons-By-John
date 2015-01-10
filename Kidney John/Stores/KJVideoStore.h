//
//  KJVideoStore.h
//  Kidney John
//
//  Created by jl on 27/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const KJVideoDataFetchDidHappenNotification;

@interface KJVideoStore : NSObject

// Init method
+ (KJVideoStore *)sharedStore;

// Class methods
+ (void)fetchVideoData;
+ (NSArray *)returnFavouritesArray;

@end
