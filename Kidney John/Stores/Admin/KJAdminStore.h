//
//  KJAdminStore.h
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJAdminStore : NSObject

// Connection state
typedef NS_ENUM(NSUInteger, KJAdminStoreConnectionState) {
    KJAdminStoreStateDisconnected,
    KJAdminStoreStateConnecting,
    KJAdminStoreStateConnected,
};

// Properties
@property (nonatomic) KJAdminStoreConnectionState connectionState;

// Methods
// Init
+ (instancetype)sharedStore;

@end
