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
// Testing/debugging
static NSString *kUsingVersion2ColourSchemeSettingKey = @"KJUsingVersion2ColourSchemeSetting";

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
+ (BOOL)kj_usingVersion2ColourSchemeSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUsingVersion2ColourSchemeSettingKey];
}

+ (void)kj_setUsingVersion2ColourSchemeSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kUsingVersion2ColourSchemeSettingKey];
}

@end
