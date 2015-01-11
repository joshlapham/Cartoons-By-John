//
//  KJDoodleStore.h
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KJRandomImage.h"

// Constants
extern NSString * const KJDoodleFetchDidHappenNotification;

@interface KJDoodleStore : NSObject

// Connection state
typedef NS_ENUM(NSUInteger, KJDoodleStoreConnectionState) {
    KJDoodleStoreStateDisconnected,
    KJDoodleStoreStateConnecting,
    KJDoodleStoreStateConnected,
};

// Properties
@property (nonatomic) KJDoodleStoreConnectionState connectionState;

// Init method
+ (KJDoodleStore *)sharedStore;

// Class methods
- (void)fetchDoodleData;
+ (NSArray *)returnArrayOfRandomImages;
+ (KJRandomImage *)returnDoodleWithDoodleUrl:(NSString *)doodleUrl;
+ (NSArray *)returnFavouritesArray;
+ (UIImage *)returnDoodleImageFromDoodleObject:(KJRandomImage *)doodleObject;

@end
