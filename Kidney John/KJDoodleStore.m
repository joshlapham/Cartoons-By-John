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
#import <SDWebImage/UIImageView+WebCache.h>
#import "SDWebImagePrefetcher.h"
#import "JPLReachabilityManager.h"

@implementation KJDoodleStore

#pragma mark - Init methods

+ (KJDoodleStore *)sharedStore
{
    static KJDoodleStore *_sharedStore = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJDoodleStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Favourite methods

+ (KJRandomImage *)returnDoodleWithDoodleUrl:(NSString *)doodleUrl
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find comic where comicNameToFind matches
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageUrl == %@", doodleUrl];
    KJRandomImage *doodleToReturn = [KJRandomImage MR_findFirstWithPredicate:predicate inContext:localContext];
    
    //NSLog(@"comic store: comic to return: %@", comicToReturn.comicName);
    
    return doodleToReturn;
}

+ (void)updateDoodleFavouriteStatus:(NSString *)doodleUrl isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext]) {
        //NSLog(@"doodleStore: doodle is NOT already a favourite, adding now ..");
        
        KJRandomImage *doodleToFavourite = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext];
        doodleToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        NSLog(@"doodleStore: doodle not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfDoodleIsAFavourite:(NSString *)doodleUrl
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext]) {
        KJRandomImage *doodleToFavourite = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext];
        if (!doodleToFavourite.isFavourite) {
            NSLog(@"doodleStore: doodle IS NOT a favourite");
            return FALSE;
        } else {
            NSLog(@"doodleStore: doodle IS a favourite");
            return TRUE;
        }
    } else {
        return FALSE;
    }
}

+ (NSArray *)returnFavouritesArray
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    NSArray *arrayToReturn = [KJRandomImage MR_findAllWithPredicate:predicate inContext:localContext];
    
    return arrayToReturn;
}

#pragma mark - Prefetch doodles method

+ (void)prefetchDoodles
{
    NSArray *resultsArray = [[NSArray alloc] init];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    resultsArray = [KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES];
    
    for (KJRandomImage *image in resultsArray) {
        NSString *urlString = image.imageUrl;
        NSURL *urlToPrefetch = [NSURL URLWithString:urlString];
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls progress:nil completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
        NSLog(@"fetched count: %d, skipped count: %d", finishedCount, skippedCount);
    }];
}

#pragma mark - Core Data methods

+ (BOOL)checkIfRandomImageIsInDatabaseWithImageUrl:(NSString *)imageUrl context:(NSManagedObjectContext *)context
{
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:context]) {
        //NSLog(@"RANDOM: Yes, random image does exist in database");
        return TRUE;
    } else {
        //NSLog(@"RANDOM: No, random image does NOT exist in database");
        return FALSE;
    }
}

+ (void)persistNewRandomImageWithId:(NSString *)imageId
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
        // DISABLED as we are using SDWebImage for caching
//        NSURL *imageUrlToFetch = [NSURL URLWithString:imageUrl];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageUrlToFetch];
//        newRandomImage.imageData = imageData;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    }
}

+ (void)checkIfImageNeedsUpdateWithId:(NSString *)imageId
                               description:(NSString *)imageDescription
                                url:(NSString *)imageUrl
                                 date:(NSString *)imageDate
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If image is in database ..
    if ([self checkIfRandomImageIsInDatabaseWithImageUrl:imageUrl context:localContext]) {
        KJRandomImage *imageToCheck = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:localContext];
        
        // Check if imageToCheck needs updating
        if (![imageToCheck.imageId isEqualToString:imageId] || ![imageToCheck.imageDescription isEqualToString:imageDescription] || ![imageToCheck.imageUrl isEqualToString:imageUrl] || ![imageToCheck.imageDate isEqualToString:imageDate]) {
            // Image needs updating
            NSLog(@"doodleStore: doodle needs update: %@", imageUrl);
            
            imageToCheck.imageId = imageId;
            imageToCheck.imageDescription = imageDescription;
            imageToCheck.imageUrl = imageUrl;
            imageToCheck.imageDate = imageDate;
            
            // Save
            //[localContext MR_saveToPersistentStoreAndWait];
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"doodleStore: updated doodle: %@", imageUrl);
                } else if (error) {
                    NSLog(@"doodleStore: error updating doodle: %@ - %@", imageUrl, [error localizedDescription]);
                }
            }];
        }
    }
}

+ (void)fetchDoodleData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"doodleStore: fetching doodle data ..");
        
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
                        // Check if image needs updating
                        [self checkIfImageNeedsUpdateWithId:object[@"imageId"] description:object[@"imageDescription"] url:object[@"imageUrl"] date:object[@"date"]];
                        
                        // Save Parse object to Core Data
                        [self persistNewRandomImageWithId:object[@"imageId"] description:object[@"imageDescription"] url:object[@"imageUrl"] date:object[@"date"]];
                    } else {
                        NSLog(@"doodleStore: image not active: %@", object[@"imageUrl"]);
                    }
                }
                // Set randomImagesFetchDone = YES in NSUserDefaults
                // NOTE - set to NO by default for debugging purposes
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRandomImagesFetchDone"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Send NSNotification to random images view
                // to say that data fetch is done
                NSString *notificationName = @"KJDoodleDataFetchDidHappen";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
                
                // Prefetch doodles if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [KJDoodleStore prefetchDoodles];
                }
                
            } else {
                // Log details of the failure
                NSLog(@"doodleStore: error: %@ %@", error, [error userInfo]);
            }
        }];
    });
}

#pragma mark - Return results methods

+ (NSArray *)returnArrayOfRandomImages
{
    NSArray *randomImagesArray = [[NSArray alloc] init];
    randomImagesArray = [KJRandomImage MR_findAll];
    
    //NSLog(@"random images array count: %d", [randomImagesArray count]);
    
    return randomImagesArray;
}

+ (UIImage *)returnDoodleImageFromDoodleObject:(KJRandomImage *)doodleObject
{
    UIImage *imageToReturn;
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:doodleObject.imageUrl]) {
        //NSLog(@"found image in cache");
        imageToReturn = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:doodleObject.imageUrl];
    } else {
        //NSLog(@"no image in cache");
        // TODO: implement fallback
    }
    
    NSLog(@"doodleStore: returning doodle image from cache: %@", imageToReturn);
    
    return imageToReturn;
}

+ (BOOL)hasInitialDataFetchHappened
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstRandomImagesFetchDone"]) {
        return YES;
    } else {
        return NO;
    }
}

@end
