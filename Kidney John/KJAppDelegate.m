//
//  KJAppDelegate.m
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJAppDelegate.h"
#import "Parse.h"
#import "JPLReachabilityManager.h"
#import "KJVideoStore.h"
#import "KJComicStore.h"
#import "KJDoodleStore.h"
#import "KJSocialLinkStore.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "NSUserDefaults+KJSettings.h"

@implementation KJAppDelegate {
    NSString *parseAppId;
    NSString *parseClientKey;
}

#pragma mark - UI methods

- (void)setupUI
{
    // TESTING - Version 2 colour scheme
    [NSUserDefaults kj_setUsingVersion2ColourSchemeSetting:NO];
    
    // Show status bar after app launch image has shown
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Set navbar colour
    [[UINavigationBar appearance] setBarTintColor:[UIColor kj_navbarColour]];
    
    // Init shadow for navbar font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor kj_navbarTitleFontShadowColour];
    shadow.shadowOffset = CGSizeMake(0, 1);
    
    // Set navbar title font, colour, shadow, etc
    NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor kj_navbarTitleFontColour],
                                    NSShadowAttributeName : shadow,
                                    NSFontAttributeName : [UIFont kj_navbarFont]
                                    };
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    // Set navbar items to white
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Change status bar text to white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set navbar items of UIActivityViews to white
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
}

#pragma mark - Read Parse.com API keys from plist method

- (void)readAPIKeysFromPlist
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"Keys.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    
    if (!temp) {
        DDLogError(@"Error reading Parse keys.plist: %@, format: %d", errorDesc, format);
    }
    
    parseAppId = [temp objectForKey:@"appId"];
    parseClientKey = [temp objectForKey:@"clientKey"];
    
//    DDLogVerbose(@"Parse App ID: %@, Client Key: %@", parseAppId, parseClientKey);
}

#pragma mark - Init methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Customize UI
    [self setupUI];
    
    // CocoaLumberjack
    // Setup XCode console logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Magical Record
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"kj.sqlite"];
    
    // Push notifications
    // Check which iOS version is running
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8
        // use registerUserNotificationSettings
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
    } else {
        // iOS 7
        // use registerForRemoteNotifications
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
#else
    // iOS 7
    // NOTE - iOS 7 is the lowest OS version this app supports
    // use registerForRemoteNotifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
    
    // Parse
    // Parse App and client ID
    // Read from Keys.plist (not checked into Git)
    [self readAPIKeysFromPlist];
    
    // Set keys after method reads from Keys.plist
    [Parse setApplicationId:parseAppId
                  clientKey:parseClientKey];
    
    // Parse security
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    // Optionally enable public read access while disabling public write access.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Parse analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Init item stores
    [KJVideoStore sharedStore];
    [KJComicStore sharedStore];
    [KJDoodleStore sharedStore];
    [KJSocialLinkStore sharedStore];
    
    // Reachability
    [JPLReachabilityManager sharedManager];
    
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Parse.com is reachable");
    } else if ([JPLReachabilityManager isUnreachable]) {
        DDLogVerbose(@"Parse.com is NOT reachable");
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

#pragma mark - Push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLogVerbose(@"Did receive push notification");
    
    [PFPush handlePush:userInfo];
}

@end
