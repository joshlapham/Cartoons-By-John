//
//  KJAppDelegate.m
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJAppDelegate.h"
#import <Parse/Parse.h>
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
#import "JPLYouTubeListView.h"
#import "KJComicListView.h"
#import "KJTabBarController.h"
#import <ParseCrashReporting/ParseCrashReporting.h>

// Constants
static NSString *kKJParsePFConfigUseVersion11ColoursKey = @"useVersion11Colours";
static NSString *kKJParsePFConfigUseSocialLinksFromParseKey = @"useSocialLinksFromParse";
static NSString *kKJParsePFConfigTrackFavouritedItemEventsWithParseAnalyticsKey = @"trackFavouritedItemEventsWithParseAnalytics";

@implementation KJAppDelegate {
    NSString *parseAppId;
    NSString *parseClientKey;
}

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - UI methods

- (void)setupUI {
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
    
    // Set title attributes
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    // Set navbar items to white
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Change status bar text to white
    // TESTING - Version 1.1 colour scheme
    if (![NSUserDefaults kj_shouldUseVersion11ColourSchemeSetting]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else {
        // Version 1.1 colour
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    // Set navbar items of UIActivityViews to white
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
}

#pragma mark - Parse.com helper methods

#pragma mark Read Parse API keys from plist method

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

#pragma mark Fetch Parse PFConfig method

- (void)setupPFConfigFromParse {
    // Get PFConfig object in background
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error && config) {
            // Init should use version 1.1 colours
            if (config[kKJParsePFConfigUseVersion11ColoursKey]) {
                NSNumber *shouldUseVersion11Colours = config[kKJParsePFConfigUseVersion11ColoursKey];
                DDLogInfo(@"PFConfig: should use version 1.1 colours: %@", [shouldUseVersion11Colours boolValue] ? @"YES" : @"NO");
                [NSUserDefaults kj_setShouldUseVersion11ColourSchemeSetting:[shouldUseVersion11Colours boolValue]];
            }
            
            // Init should use social links from Parse
            if (config[kKJParsePFConfigUseSocialLinksFromParseKey]) {
                NSNumber *shouldUseSocialLinks = config[kKJParsePFConfigUseSocialLinksFromParseKey];
                DDLogInfo(@"PFConfig: should use social links from Parse: %@", [shouldUseSocialLinks boolValue] ? @"YES" : @"NO");
                [NSUserDefaults kj_setShouldUseSocialLinksFromParseSetting:[shouldUseSocialLinks boolValue]];
            }
            
            // Init should track favourited item events with Parse Analytics
            if (config[kKJParsePFConfigTrackFavouritedItemEventsWithParseAnalyticsKey]) {
                NSNumber *shouldTrackEventsWithAnalytics = config[kKJParsePFConfigTrackFavouritedItemEventsWithParseAnalyticsKey];
                DDLogInfo(@"PFConfig: should track favourited item events with Parse Analytics: %@", [shouldTrackEventsWithAnalytics boolValue] ? @"YES" : @"NO");
                [NSUserDefaults kj_setShouldTrackFavouritedItemEventsWithParseSetting:[shouldTrackEventsWithAnalytics boolValue]];
            }
            
            // Sync NSUserDefaults
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        // TODO: handle error
        else {
            DDLogError(@"Error fetching PFConfig from Parse");
        }
    }];
}

#pragma mark - App version check helper methods

// Helper method to set NSUserDefaults on app launch
- (void)checkAppVersion {
    // TESTING - Version 1.1 colour scheme
    if (![NSUserDefaults kj_hasAppCompletedVersion11FirstLaunchSetting]) {
        // Force Version 1.1 colour scheme.
        // After this, value can be changed from PFConfig.
        [NSUserDefaults kj_setShouldUseVersion11ColourSchemeSetting:YES];
        [NSUserDefaults kj_setHasAppCompletedVersion11FirstLaunchSetting:YES];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Init methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Init prefs for Settings
    // NOTE - IMPORTANT to comment this out for App Store release!
    //    NSDictionary *userDefaultsDefaults = @{ @"KJUsingVersion2ColourSchemeSetting" : [NSNumber numberWithBool:NO] };
    //    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    // Do app version checks
    [self checkAppVersion];
    
    // Customize UI
    [self setupUI];
    
    // Init NSNotification observer if dynamic type font size changes.
    // This would be done by the user in Settings.
    // All this does is call setupUI method on App Delegate to re-apply navbar font size.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupUI)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // CocoaLumberjack
    // Setup XCode console logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Push notifications
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    
    // Parse
    // Parse App and client ID
    // Read from Keys.plist (not checked into Git)
    [self readAPIKeysFromPlist];
    
    // If parseAppId is nil then Keys.plist is most likely missing from the project
    NSAssert(parseAppId, @"Failed to load Parse.com keys from Keys.plist. Is the file present?");
    
    // Init Parse crash reporting
    [ParseCrashReporting enable];
    
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
    
    // Init PFConfig
    [self setupPFConfigFromParse];
    
    // Init item stores
    [KJVideoStore sharedStore];
    [KJComicStore sharedStore];
    [KJDoodleStore sharedStore];
    [KJSocialLinkStore sharedStore];
    
    // Core Data
    // Pass NSManagedObjectContext to initial view set in storyboard
    KJTabBarController *tabBarController = (KJTabBarController *)self.window.rootViewController;
    UINavigationController *navController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:0];
    JPLYouTubeListView *initialViewController = (JPLYouTubeListView *)navController.topViewController;
    initialViewController.managedObjectContext = self.managedObjectContext;
    
    // Pass to comics list view
    UINavigationController *comicsNavController = (UINavigationController *)[tabBarController.viewControllers objectAtIndex:1];
    KJComicListView *comicListViewController = (KJComicListView *)comicsNavController.topViewController;
    comicListViewController.managedObjectContext = self.managedObjectContext;
    
    // Pass managedObjectContext to stores
    [KJVideoStore sharedStore].managedObjectContext = self.managedObjectContext;
    [KJComicStore sharedStore].managedObjectContext = self.managedObjectContext;
    [KJDoodleStore sharedStore].managedObjectContext = self.managedObjectContext;
    
    // Reachability
    [JPLReachabilityManager sharedManager];
    
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"Parse.com is reachable");
    }
    else if ([JPLReachabilityManager isUnreachable]) {
        DDLogVerbose(@"Parse.com is NOT reachable");
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogVerbose(@"Did receive push notification");
    
    [PFPush handlePush:userInfo];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.joshlapham.Hacker_News_Reader" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Kidney John" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Init options for persistent store to handle lightweight migrations
    NSDictionary *persistentStoreOptions = @{
                                             NSMigratePersistentStoresAutomaticallyOption : @YES,
                                             NSInferMappingModelAutomaticallyOption : @YES
                                             };
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"kj.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:persistentStoreOptions error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
