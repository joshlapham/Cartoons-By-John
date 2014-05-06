//
//  KJComicStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJComic.h"

@interface KJComicStore : NSObject

+ (void)fetchComicData;
+ (KJComic *)returnComicWithComicName:(NSString *)comicName;
+ (void)updateComicFavouriteStatus:(NSString *)comicName isFavourite:(BOOL)isOrNot;
+ (BOOL)checkIfComicIsAFavourite:(NSString *)comicName;
- (NSArray *)returnArrayOfComicFiles;
- (UIImage *)returnComicImageFromComicObject:(KJComic *)comicObject;
+ (UIImage *)returnComicThumbImageFromComicObject:(KJComic *)comicObject;
- (NSString *)returnFilepathForComicObject:(KJComic *)comicObject;
+ (NSString *)returnThumbnailFilepathForComicObject:(KJComic *)comicObject;
+ (NSArray *)returnFavouritesArray;
+ (BOOL)hasInitialDataFetchHappened;

@end
