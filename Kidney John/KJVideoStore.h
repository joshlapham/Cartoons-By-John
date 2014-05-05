//
//  KJVideoStore.h
//  Kidney John
//
//  Created by jl on 27/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJVideoStore : NSObject

- (void)fetchVideoData;
+ (void)updateVideoFavouriteStatus:(NSString *)videoId isFavourite:(BOOL)isOrNot;
+ (BOOL)checkIfVideoIdIsAFavourite:(NSString *)videoId;

@end
