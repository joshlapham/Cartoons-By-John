//
//  KJDoodleStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJRandomImage.h"

@interface KJDoodleStore : NSObject

// Init method
+ (KJDoodleStore *)sharedStore;

// Class methods
+ (void)fetchDoodleData;
+ (NSArray *)returnArrayOfRandomImages;
+ (KJRandomImage *)returnDoodleWithDoodleUrl:(NSString *)doodleUrl;
+ (void)updateDoodleFavouriteStatus:(NSString *)doodleUrl isFavourite:(BOOL)isOrNot;
+ (BOOL)checkIfDoodleIsAFavourite:(NSString *)doodleUrl;
+ (NSArray *)returnFavouritesArray;
+ (UIImage *)returnDoodleImageFromDoodleObject:(KJRandomImage *)doodleObject;
+ (BOOL)hasInitialDataFetchHappened;

@end
