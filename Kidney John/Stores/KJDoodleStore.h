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
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) KJDoodleStoreConnectionState connectionState;

// Init method
+ (KJDoodleStore *)sharedStore;

// Other methods
- (void)fetchDoodleData;
- (NSArray *)returnDoodlesArray;
- (NSArray *)returnFavouritesArray;
- (void)flushLocalDoodlesInContext:(NSManagedObjectContext *)context;

@end
