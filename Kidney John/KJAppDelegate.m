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
#import "Models/KJVideo.h"
#import "Models/KJComicFromParse.h"
#import "Models/KJRandomImageFromParse.h"
#import "Models/KJRandomImage.h"
#import "Models/KJComic.h"
#import "MBProgressHUD.h"

@implementation KJAppDelegate

#pragma mark - UI methods

- (void)setupUI
{
    // Set navbar colour
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1]];
}

#pragma mark - Core Data methods

#pragma mark Videos

- (BOOL)checkIfVideoIsInDatabaseWithVideoId:(NSString *)videoId context:(NSManagedObjectContext *)context
{
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:context]) {
        //NSLog(@"Yes, video does exist in database");
        return TRUE;
    } else {
        //NSLog(@"No, video does NOT exist in database");
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

#pragma mark Doodles

- (BOOL)checkIfRandomImageIsInDatabaseWithImageUrl:(NSString *)imageUrl context:(NSManagedObjectContext *)context
{
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:context]) {
        //NSLog(@"RANDOM: Yes, random image does exist in database");
        return TRUE;
    } else {
        //NSLog(@"RANDOM: No, random image does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewRandomImageWithId:(NSString *)imageId
                        description:(NSString *)imageDescription
                                url:(NSString *)imageUrl
                               date:(NSString *)imageDate
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If doodle does not exist in database then persist
    if (![self checkIfRandomImageIsInDatabaseWithImageUrl:imageUrl context:localContext]) {
        // Create a new doodle in the current context
        KJRandomImage *newRandomImage = [KJRandomImage MR_createInContext:localContext];
        
        // Set attributes
        newRandomImage.imageId = imageId;
        newRandomImage.imageDescription = imageDescription;
        newRandomImage.imageUrl = imageUrl;
        //newRandomImage.imageDate = imageDate;
        // Thumbnails
        NSURL *imageUrlToFetch = [NSURL URLWithString:imageUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrlToFetch];
        newRandomImage.imageData = imageData;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark Comics

- (BOOL)checkIfComicIsInDatabaseWithName:(NSString *)comicName context:(NSManagedObjectContext *)context
{
    if ([KJComic MR_findFirstByAttribute:@"comicName" withValue:comicName inContext:context]) {
        //NSLog(@"COMICS LIST: yes, comic does exist in database");
        return TRUE;
    } else {
        //NSLog(@"COMICS LIST: no, comic does NOT exist in database");
        return FALSE;
    }
}

- (void)persistNewComicWithName:(NSString *)comicName
                      comicData:(NSString *)comicData
                 comicThumbData:(NSData *)comicThumbData
                  comicFileName:(NSString *)comicFileName
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If comic does not exist in database then persist
    if (![self checkIfComicIsInDatabaseWithName:comicName context:localContext]) {
        // Create a new comic in the current context
        KJComic *newComic = [KJComic MR_createInContext:localContext];
        
        // Set attributes
        newComic.comicName = comicName;
        newComic.comicData = comicData;
        newComic.comicThumbData = comicThumbData;
        newComic.comicFileName = comicFileName;
        
        // Set comic file data from comicData string
        NSURL *comicDataUrl = [NSURL URLWithString:comicData];
        newComic.comicFileData = [NSData dataWithContentsOfURL:comicDataUrl];
        
        // DEBUGGING
        NSLog(@"CORE DATA: %@", newComic.comicData);
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark - Fetch data methods

#pragma mark random image fetch method

- (void)callDoodleFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"DOODLE PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *randomQuery = [KJRandomImageFromParse query];
        
        // Query all random image urls
        [randomQuery whereKey:@"imageUrl" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [randomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        //[self persis:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                        [self persistNewRandomImageWithId:object[@"imageId"] description:object[@"imageDescription"] url:object[@"imageUrl"] date:object[@"date"]];
                    } else {
                        NSLog(@"RANDOM: image not active: %@", object[@"imageUrl"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set randomImagesFetchDone = YES in NSUserDefaults
            // NOTE - set to NO by default for debugging purposes
            //[[NSUserDefaults standardUserDefaults] setObject:Nil forKey:@"randomImagesFetchDone"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"RANDOM PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark fetch videos method

- (void)callVideoFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"VIDEO PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
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
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
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
            NSLog(@"VIDEO PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark Fetch comics method

- (void)callComicsFetchMethod
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"COMICS PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Setup query
        PFQuery *comicsQuery = [KJComicFromParse query];
        
        // Query all videos
        [comicsQuery whereKey:@"comicName" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [comicsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
                        //[self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"]];
                        PFFile *thumbImageFile = [object objectForKey:@"comicThumb"];
                        PFFile *comicImageFile = [object objectForKey:@"comicFile"];
                        
                        //NSLog(@"COMIC LIST: PFFile URL: %@", thumbImageFile.url);
                        [thumbImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                [self persistNewComicWithName:object[@"comicName"]
                                                    comicData:comicImageFile.url
                                               comicThumbData:data
                                                comicFileName:object[@"comicFileName"]];
                            }
                            //[self.collectionView reloadData];
                            
                            //NSString *notificationName = @"KJComicDataFetchDidHappen";
                            //[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
                        }];
                        
                    } else {
                        NSLog(@"COMIC LIST: comic not active: %@", object[@"comicName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"comicLoadDone"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"COMICS PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark fetch all data method

- (void)fetchAllData
{
    // Show network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Show progress
    // NOTE - not working
    // Review which view to add this to since it's called from the app delegate
//    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
//    hud.labelText = @"Loading new stuff ...";
    
    // Call data fetch methods for video and doodles
    [self callVideoFetchMethod];
    [self callDoodleFetchMethod];
    [self callComicsFetchMethod];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Init methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Customize UI
    [self setupUI];
    
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
    // NOTE - disabled
//    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"firstLoadDone"] isEqualToString:@"1"]) {
//        NSLog(@"DELEGATE: firstLoad has already been completed, assuming data is in Core Data already");
//    } else {
//        [self callFetchMethod];
//    }
    
    // Fetch all data from Parse and persist to Core Data
    [self fetchAllData];
    
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
