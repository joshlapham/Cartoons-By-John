//
//  NSUserDefaults+KJSettings.m
//  Kidney John
//
//  Created by jl on 9/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "NSUserDefaults+KJSettings.h"

// Constants
static NSString *kHasAppCompletedFirstLaunchSettingKey = @"kHasAppCompletedFirstLaunchSettingKey";
static NSString *kHasFirstVideoFetchCompletedSettingKey = @"firstVideoFetchDone";

@implementation NSUserDefaults (KJSettings)

// App first launch setting
+ (BOOL)kj_hasAppCompletedFirstLaunchSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasAppCompletedFirstLaunchSettingKey];
}

+ (void)kj_setHasAppCompletedFirstLaunchSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasAppCompletedFirstLaunchSettingKey];
}

// Videos
// Has first video fetch completed setting
+ (BOOL)kj_hasFirstVideoFetchCompletedSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasFirstVideoFetchCompletedSettingKey];
}

+ (void)kj_setHasFirstVideoFetchCompletedSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasFirstVideoFetchCompletedSettingKey];
}

@end
