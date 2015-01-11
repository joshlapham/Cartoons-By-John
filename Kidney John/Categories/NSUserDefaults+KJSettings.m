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
static NSString *kHasFirstComicFetchCompletedSettingKey = @"firstComicFetchDone";
static NSString *kHasFirstDoodleFetchCompletedSettingKey = @"firstRandomImagesFetchDone";
static NSString *kHasFirstSocialLinksFetchCompletedSettingKey = @"firstSocialLinksFetchDone";

// Version 1.1
static NSString *kHasAppCompletedVersion11FirstLaunchSettingKey = @"kHasAppCompletedVersion11FirstLaunchSettingKey";
static NSString *kShouldUseVersion11ColourSchemeKey = @"KJShouldUseVersion11ColourScheme";

@implementation NSUserDefaults (KJSettings)

// App first launch setting
+ (BOOL)kj_hasAppCompletedFirstLaunchSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasAppCompletedFirstLaunchSettingKey];
}

+ (void)kj_setHasAppCompletedFirstLaunchSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasAppCompletedFirstLaunchSettingKey];
}

// Version 1.1 first launch setting
+ (BOOL)kj_hasAppCompletedVersion11FirstLaunchSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasAppCompletedFirstLaunchSettingKey];
}

+ (void)kj_setHasAppCompletedVersion11FirstLaunchSetting:(BOOL)setting {
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

// Comics
// Has first comic fetch completed setting
+ (BOOL)kj_hasFirstComicFetchCompletedSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasFirstComicFetchCompletedSettingKey];
}

+ (void)kj_setHasFirstComicFetchCompletedSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasFirstComicFetchCompletedSettingKey];
}

// Doodles
// Has first doodle fetch completed setting
+ (BOOL)kj_hasFirstDoodleFetchCompletedSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasFirstDoodleFetchCompletedSettingKey];
}

+ (void)kj_setHasFirstDoodleFetchCompletedSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasFirstDoodleFetchCompletedSettingKey];
}

// Social Links
// Has first social links fetch completed setting
+ (BOOL)kj_hasFirstSocialLinksFetchCompletedSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasFirstSocialLinksFetchCompletedSettingKey];
}

+ (void)kj_setHasFirstSocialLinksFetchCompletedSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasFirstSocialLinksFetchCompletedSettingKey];
}

// Testing/debugging
// Colour schemes
+ (BOOL)kj_shouldUseVersion11ColourSchemeSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldUseVersion11ColourSchemeKey];
}

+ (void)kj_setShouldUseVersion11ColourSchemeSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldUseVersion11ColourSchemeKey];
}

@end
