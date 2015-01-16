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

// Connection state
typedef NS_ENUM(NSUInteger, KJComicStoreConnectionState) {
    KJComicStoreStateDisconnected,
    KJComicStoreStateConnecting,
    KJComicStoreStateConnected,
};

// Properties
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) KJComicStoreConnectionState connectionState;

// Init method
+ (KJComicStore *)sharedStore;

// Class methods
- (void)fetchComicData;
- (NSArray *)returnFavouritesArray;
- (NSArray *)returnComicsArray;

@end
