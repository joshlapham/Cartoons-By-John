//
//  KJAppDelegate.m
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJAppDelegate.h"
#import "Parse.h"
#import "KJVideo.h"

@implementation KJAppDelegate

@synthesize videosArrayToSendToDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // PARSE SETUP
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
    
    // Parse custom class setup
    [KJVideo registerSubclass];
    
    // Fetch all locations from Parse
    // and store in array in SchnittyDayProtocol
    JPLYouTubeVideoProtocol *videoProtocol = [[JPLYouTubeVideoProtocol alloc] init];
    videoProtocol.delegate = self;
    
    // Fetch locations
    // Query Location Parse class
    PFQuery *query = [PFQuery queryWithClassName:@"Video"];
    
    // Query all videos
    [query whereKey:@"videoName" notEqualTo:@"LOL"];
    
    // Start query with block
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d locations", (unsigned long)objects.count);
            // Do something with the found objects
            
            self.videosArrayToSendToDelegate = [NSMutableArray array];
            
            for (PFObject *object in objects) {
                // PFClass for locations
                KJVideo *video = [[KJVideo alloc] init];
                [video setVideoId:object[@"videoId"]];
                [video setVideoName:object[@"videoName"]];
                [video setVideoDescription:object[@"videoDescription"]];
                
                // Date
                NSString *dateString = object[@"date"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyy-MM-dd";
                NSDate *formattedDate = [dateFormatter dateFromString:dateString];
                dateFormatter.dateFormat = @"dd-MMM-yyyy";
                NSLog(@"%@",[dateFormatter stringFromDate:formattedDate]);
                // Add newly formatted date
                //[video setVideoDate:object[@"date"]];
                [video setVideoDate:formattedDate];
                
                //__block NSMutableArray *videosArrayToSendToDelegate = [[NSMutableArray alloc] init];
                //[locations addObject:location];
                [[self videosArrayToSendToDelegate] addObject:video];
                //NSLog(@"LOCATIONS OBJECT: %@", location);
                //[videoProtocol updateVideosArrayWithVideo:video];
                //NSLog(@"LOCATIONS ARRAY: %@", [dayOfWeekProto locationsArray]);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        // Set delegate's locations array
        [videoProtocol setVideosArray:[self videosArrayToSendToDelegate]];
        NSLog(@"Fetched and stored a total of %lu videos", (unsigned long)[[videoProtocol videosArray] count]);
        //[dayOfWeekProto returnLocationForGivenWeekday:@"Monday"];
        //[dayOfWeekProto returnLocationForGivenWeekday:@"Wednesday"];
        //                [dayOfWeekProto updateCurrentUserLocationWithGeoPoint:geoPoint];
    }];
    
    // TESTING
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *documentsPath = [resourcePath stringByAppendingPathComponent:@"Comics"];
    NSError *error;
    NSArray *comicThumbImages = [[NSArray alloc] init];
    comicThumbImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    for (id obj in comicThumbImages) {
        NSLog(@"File: %@", obj);
    }
    NSLog(@"IMG ARRAY: %@", [comicThumbImages objectAtIndex:0]);
    // END OF TESTING
    
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
}

@end
