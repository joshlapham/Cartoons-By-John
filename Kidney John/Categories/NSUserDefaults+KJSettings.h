//
//  NSUserDefaults+KJSettings.h
//  Kidney John
//
//  Created by jl on 9/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (KJSettings)

// App first launch setting
+ (BOOL)kj_hasAppCompletedFirstLaunchSetting;
+ (void)kj_setHasAppCompletedFirstLaunchSetting:(BOOL)setting;

// Videos
// First video fetch completed setting
+ (BOOL)kj_hasFirstVideoFetchCompletedSetting;
+ (void)kj_setHasFirstVideoFetchCompletedSetting:(BOOL)setting;

// Comics
// First comic fetch completed setting
+ (BOOL)kj_hasFirstComicFetchCompletedSetting;
+ (void)kj_setHasFirstComicFetchCompletedSetting:(BOOL)setting;

// Doodles
// First doodle fetch completed setting
+ (BOOL)kj_hasFirstDoodleFetchCompletedSetting;
+ (void)kj_setHasFirstDoodleFetchCompletedSetting:(BOOL)setting;

@end
