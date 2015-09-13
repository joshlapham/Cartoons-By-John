//
//  KJAppDelegate+AppVersionChecks.m
//  Kidney John
//
//  Created by Josh Lapham on 13/09/2015.
//  Copyright © 2015 Josh Lapham. All rights reserved.
//

#import "KJAppDelegate+AppVersionChecks.h"
#import "NSUserDefaults+KJSettings.h"
#import "KJDoodleStore.h"

@implementation KJAppDelegate (AppVersionChecks)

#pragma mark - App version check helper methods

// Helper method to set NSUserDefaults on app launch
- (void)checkAppVersion {
    // Initial first app launch
    if (![NSUserDefaults kj_hasAppCompletedFirstLaunchSetting]) {
        [NSUserDefaults kj_setHasAppCompletedFirstLaunchSetting:YES];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Version 1.1.2
    [self doVersion112Checks];
}

// Version 1.1.2
- (void)doVersion112Checks {
    if (![NSUserDefaults kj_hasAppCompletedVersion112FirstLaunchSetting]) {
        // Flush all doodles locally
        // NOTE - only flushing if doodle data fetch has happened
        if ([NSUserDefaults kj_hasFirstDoodleFetchCompletedSetting]) {
            // NOTE - doing this as there was an issue with more than half of all doodle image URLs just prior to version 1.1.2 being submitted to App Store. Image URLs were updated on server side, but there was a bug in the app code which caused older doodle images already existing in Core Data locally not to be updated. Forcing deletion of all local doodle images here as a quick workaround.
            [[KJDoodleStore sharedStore] flushLocalDoodlesInContext:self.managedObjectContext];
            
            [NSUserDefaults kj_setHasAppCompletedVersion112FirstLaunchSetting:YES];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end
