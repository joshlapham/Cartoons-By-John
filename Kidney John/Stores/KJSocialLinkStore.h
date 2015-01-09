//
//  KJSocialLinkStore.h
//  Kidney John
//
//  Created by jl on 15/11/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const KJSocialLinkDataFetchDidHappenNotification;

@interface KJSocialLinkStore : NSObject

// Init method
+ (KJSocialLinkStore *)sharedStore;

// Class methods
+ (void)fetchSocialLinkData;
+ (BOOL)hasInitialDataFetchHappened;

@end
