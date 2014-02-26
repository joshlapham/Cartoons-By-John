//
//  KJDoodleStore.m
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleStore.h"
#import "Parse.h"
#import "KJRandomImageFromParse.h"
#import "KJRandomImage.h"

@implementation KJDoodleStore

#pragma mark - Core Data methods

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

- (void)fetchDoodleData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"DOODLE PARSE FETCH: IN GCD DEFAULT QUEUE THREAD ...");
        
        // Show progress
        //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud.labelText = @"Loading doodles ...";
        
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
                // Do something with the found objects
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Save Parse object to Core Data
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
            
            // Send NSNotification to random images view
            // to say that data fetch is done
            NSString *notificationName = @"KJDoodleDataFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"RANDOM PARSE FETCH: IN GCD MAIN QUEUE THREAD ...");
        });
        
    });
}

#pragma mark - Get random images array

- (NSArray *)getRandomImagesArray
{
    NSArray *randomImagesArray = [[NSArray alloc] init];
    randomImagesArray = [KJRandomImage MR_findAll];
    
    //NSLog(@"random images array count: %d", [randomImagesArray count]);
    
    return randomImagesArray;
}

#pragma mark - init methods

- (id)initDoodleStore
{
    self = [super init];
    if (self) {
        // inits
        //[self fetchDoodleData];
    }
    return self;
}

@end
