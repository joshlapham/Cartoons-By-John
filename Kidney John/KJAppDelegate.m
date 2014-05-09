//
//  KJAppDelegate.m
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJAppDelegate.h"
#import "Parse.h"
#import "Models/KJVideoFromParse.h"
#import "Models/KJComicFromParse.h"
#import "Models/KJRandomImageFromParse.h"
#import "JPLReachabilityManager.h"
#import "KJVideoStore.h"
#import "KJComicStore.h"
#import "KJDoodleStore.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation KJAppDelegate

#pragma mark - UI methods

- (void)setupUI
{
    // Show status bar after app launch image has shown
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Set navbar colour
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1]];
    
    // Set navbar font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont fontWithName:@"JohnRoderickPaine" size:21.0], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    // Set navbar items to white
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Change status bar text to white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set navbar items of UIActivityViews to white
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    
// For getting screenshot of app for app launch image
#ifdef SCREENSHOT
#warning Screenshot Mode enabled!
    self.window.rootViewController.view.backgroundColor = [UIColor whiteColor];
    
    // TODO: resize navbar to allow for no status bar
    CGRect sizeOfStatusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect originalNavbarSize = self.window.rootViewController.navigationController.navigationBar.frame;
    
    NSLog(@"size of status bar: %@, size of navbar: %@", NSStringFromCGRect(sizeOfStatusBar), NSStringFromCGRect(originalNavbarSize));
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //[[UINavigationBar appearance] setFrame:navBarSizeToResizeTo];
    
#endif
}

#pragma mark - Init methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Customize UI
    [self setupUI];
    
    // CocoaLumberjack
    // Setup XCode console logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // MAGICAL RECORD
    //[MagicalRecord setupCoreDataStackWithStoreNamed:@"kj.sqlite"];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"kj.sqlite"];
    
    // PARSE
    // Parse custom class setup
    [KJVideoFromParse registerSubclass];
    [KJRandomImageFromParse registerSubclass];
    [KJComicFromParse registerSubclass];
    
    // Parse App ID:
    // IDGldVVzggf7F2YBimgm7l9Cn1YOktzzy3BbNSkm
    // Parse Client ID:
    // VqeQO1YqbioimMbrzD6SMlOKdjvr6VCj6gZqj3VY
    [Parse setApplicationId:@"IDGldVVzggf7F2YBimgm7l9Cn1YOktzzy3BbNSkm"
                  clientKey:@"VqeQO1YqbioimMbrzD6SMlOKdjvr6VCj6gZqj3VY"];
    
    // Parse security
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    // Optionally enable public read access while disabling public write access.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    // Parse analytics
    //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Init item stores
    [KJVideoStore sharedStore];
    [KJComicStore sharedStore];
    [KJDoodleStore sharedStore];
    
    // Reachability
    [JPLReachabilityManager sharedManager];
    
    if ([JPLReachabilityManager isReachable]) {
        NSLog(@"Parse.com is reachable");
    } else if ([JPLReachabilityManager isUnreachable]) {
        NSLog(@"Parse.com is NOT reachable");
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

@end
