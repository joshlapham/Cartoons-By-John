//
//  KJComicStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KJComic;

// Constants
extern NSString * const KJComicDataFetchDidHappenNotification;

@interface KJComicStore : NSObject

// Init method
+ (KJComicStore *)sharedStore;

// Class methods
+ (void)fetchComicData;
+ (KJComic *)returnComicWithComicName:(NSString *)comicName;
- (NSArray *)returnArrayOfComicFiles;
+ (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject;
+ (UIImage *)returnComicThumbImageFromComicObject:(KJComic *)comicObject;
+ (NSString *)returnFilepathForComicObject:(KJComic *)comicObject;
+ (NSString *)returnThumbnailFilepathForComicObject:(KJComic *)comicObject;
+ (NSArray *)returnFavouritesArray;

@end
