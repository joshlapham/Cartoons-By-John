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
#import "Models/KJRandomImageFromParse.h"
#import "Models/KJVideo.h"
#import "Models/KJComicFromParse.h"

@implementation KJAppDelegate

#pragma mark - Core Data methods
- (BOOL)checkIfVideoIsInDatabaseWithVideoId:(NSString *)videoId context:(NSManagedObjectContext *)context
{
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:context]) {
        NSLog(@"Yes, video does exist in database");
        return TRUE;
    } else {
        NSLog(@"No, video does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewVideoWithId:(NSString *)videoId
                         name:(NSString *)videoName
                  description:(NSString *)videoDescription
                         date:(NSString *)videoDate
                   cellHeight:(NSString *)videoCellHeight
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If video does not exist in database then persist
    if (![self checkIfVideoIsInDatabaseWithVideoId:videoId context:localContext]) {
        // Create a new video in the current context
        KJVideo *newVideo = [KJVideo MR_createInContext:localContext];
        
        // Set attributes
        newVideo.videoId = videoId;
        newVideo.videoName = videoName;
        newVideo.videoDescription = videoDescription;
        newVideo.videoDate = videoDate;
        newVideo.videoCellHeight = videoCellHeight;
        // Thumbnails
        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", videoId];
        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
        NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
        newVideo.videoThumb = thumbData;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Fetch videos method
- (void)callFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *query = [KJVideoFromParse query];
        
        // Query all videos
        [query whereKey:@"videoName" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        [self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                    } else {
                        NSLog(@"VIDEO LIST: video not active: %@", object[@"videoName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLoadDone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *notificationName = @"KJDataFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark - Init methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // MAGICAL RECORD
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"kj.sqlite"];
    
    // PARSE SETUP
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
    
    // Fetch initial data from Parse.com and persist to Core Data if app hasn't been loaded before
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"firstLoadDone"] isEqualToString:@"1"]) {
        NSLog(@"DELEGATE: firstLoad has already been completed, assuming data is in Core Data already");
    } else {
        [self callFetchMethod];
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
