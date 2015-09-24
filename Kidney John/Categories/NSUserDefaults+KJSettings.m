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
static NSString *kShouldUseVersion11ColourSchemeKey = @"KJShouldUseVersion11ColourScheme";

// Version 1.1.2
static NSString *kHasAppCompletedVersion112FirstLaunchSettingKey = @"kHasAppCompletedVersion112FirstLaunchSettingKey";

// Testing social links from Parse
static NSString *kShouldUseSocialLinksFromParseSettingKey = @"KJShouldUseSocialLinksFromParseSettingKey";

// Parse Analytics
static NSString * kShouldTrackFavouritedItemEventsWithParseSettingKey = @"KJShouldTrackFavouritedItemEventsWithParseSettingKey";
static NSString * kShouldTrackPlayedVideoEventsWithParseSettingKey = @"KJShouldTrackPlayedVideoEventsWithParseSettingKey";
static NSString * kShouldTrackViewedComicEventsWithParseSettingKey = @"KJShouldTrackViewedComicEventsWithParseSettingKey";
static NSString * kShouldTrackViewedDoodleEventsWithParseSettingKey = @"KJShouldTrackViewedDoodleEventsWithParseSettingKey";

@implementation NSUserDefaults (KJSettings)

// App first launch setting
+ (BOOL)kj_hasAppCompletedFirstLaunchSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasAppCompletedFirstLaunchSettingKey];
}

+ (void)kj_setHasAppCompletedFirstLaunchSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasAppCompletedFirstLaunchSettingKey];
}

// Version 1.1.2 first launch setting
+ (BOOL)kj_hasAppCompletedVersion112FirstLaunchSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasAppCompletedVersion112FirstLaunchSettingKey];
}

+ (void)kj_setHasAppCompletedVersion112FirstLaunchSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kHasAppCompletedVersion112FirstLaunchSettingKey];
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
// Testing social links from Parse
+ (BOOL)kj_shouldUseSocialLinksFromParseSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldUseSocialLinksFromParseSettingKey];
    
}

+ (void)kj_setShouldUseSocialLinksFromParseSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldUseSocialLinksFromParseSettingKey];
}

// Parse Analytics
+ (BOOL)kj_shouldTrackFavouritedItemEventsWithParseSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldTrackFavouritedItemEventsWithParseSettingKey];
}

+ (void)kj_setShouldTrackFavouritedItemEventsWithParseSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldTrackFavouritedItemEventsWithParseSettingKey];
}

+ (BOOL)kj_shouldTrackPlayedVideoEventsWithParseSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldTrackPlayedVideoEventsWithParseSettingKey];
}

+ (void)kj_setShouldTrackPlayedVideoEventsWithParseSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldTrackPlayedVideoEventsWithParseSettingKey];
}

+ (BOOL)kj_shouldTrackViewedComicEventsWithParseSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldTrackViewedComicEventsWithParseSettingKey];
}

+ (void)kj_setShouldTrackViewedComicEventsWithParseSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldTrackViewedComicEventsWithParseSettingKey];
}

+ (BOOL)kj_shouldTrackViewedDoodleEventsWithParseSetting {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldTrackViewedDoodleEventsWithParseSettingKey];
}

+ (void)kj_setShouldTrackViewedDoodleEventsWithParseSetting:(BOOL)setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting
                                            forKey:kShouldTrackViewedDoodleEventsWithParseSettingKey];
}

@end
