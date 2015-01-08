//
//  KJDoodleStore.m
//  Kidney John
//
//  Created by jl on 26/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJDoodleStore.h"
#import "Parse.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SDWebImagePrefetcher.h"
#import "JPLReachabilityManager.h"

// Constants for Parse object keys
static NSString *kParseImageIdKey = @"imageId";
static NSString *kParseImageDescriptionKey = @"imageDescription";
static NSString *kParseImageUrlKey = @"imageUrl";
static NSString *kParseImageDateKey = @"date";

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

#pragma mark - Return results methods

+ (NSArray *)returnArrayOfRandomImages
{
    NSArray *randomImagesArray = [[NSArray alloc] initWithArray:[KJRandomImage MR_findAll]];
    
    return randomImagesArray;
}

+ (UIImage *)returnDoodleImageFromDoodleObject:(KJRandomImage *)doodleObject
{
    UIImage *imageToReturn;
    
    // SDWebImage
    // check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:doodleObject.imageUrl]) {
        //DDLogVerbose(@"found image in cache");
        imageToReturn = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:doodleObject.imageUrl];
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback
    }
    
    DDLogVerbose(@"doodleStore: returning doodle image from cache: %@", imageToReturn);
    
    return imageToReturn;
}

#pragma mark - Favourite methods

+ (KJRandomImage *)returnDoodleWithDoodleUrl:(NSString *)doodleUrl
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Find Doodle where imageUrl matches
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageUrl == %@", doodleUrl];
    
    KJRandomImage *doodleToReturn = [KJRandomImage MR_findFirstWithPredicate:predicate inContext:localContext];
    
    return doodleToReturn;
}

+ (void)updateDoodleFavouriteStatus:(NSString *)doodleUrl isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext]) {
        // Doodle is NOT a favourite
        DDLogVerbose(@"doodleStore: doodle is NOT already a favourite, adding now ..");
        
        KJRandomImage *doodleToFavourite = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext];
        doodleToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        DDLogVerbose(@"doodleStore: doodle not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfDoodleIsAFavourite:(NSString *)doodleUrl
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext]) {
        KJRandomImage *doodleToFavourite = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:doodleUrl inContext:localContext];
        if (!doodleToFavourite.isFavourite) {
            DDLogVerbose(@"doodleStore: doodle IS NOT a favourite");
            return FALSE;
        } else {
            DDLogVerbose(@"doodleStore: doodle IS a favourite");
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
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[KJRandomImage MR_findAllSortedBy:@"imageId" ascending:YES]];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    for (KJRandomImage *image in resultsArray) {
        NSString *urlString = image.imageUrl;
        NSURL *urlToPrefetch = [NSURL URLWithString:urlString];
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls progress:nil completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
        DDLogVerbose(@"doodleStore: prefetched images count: %d, skipped: %d", finishedCount, skippedCount);
    }];
}

#pragma mark - Core Data methods

+ (BOOL)hasInitialDataFetchHappened
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstRandomImagesFetchDone"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkIfRandomImageIsInDatabaseWithImageUrl:(NSString *)imageUrl context:(NSManagedObjectContext *)context
{
    if ([KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:context]) {
        //DDLogVerbose(@"RANDOM: Yes, random image does exist in database");
        return TRUE;
    } else {
        //DDLogVerbose(@"RANDOM: No, random image does NOT exist in database");
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
    
    // If Doodle does not exist in database then persist
    if (![self checkIfRandomImageIsInDatabaseWithImageUrl:imageUrl context:localContext]) {
        // Create a new Doodle in the current context
        KJRandomImage *newRandomImage = [KJRandomImage MR_createInContext:localContext];
        
        // Set attributes
        newRandomImage.imageId = imageId;
        newRandomImage.imageDescription = imageDescription;
        newRandomImage.imageUrl = imageUrl;
        newRandomImage.imageDate = imageDate;
        
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
            DDLogVerbose(@"doodleStore: doodle needs update: %@", imageUrl);
            
            imageToCheck.imageId = imageId;
            imageToCheck.imageDescription = imageDescription;
            imageToCheck.imageUrl = imageUrl;
            imageToCheck.imageDate = imageDate;
            
            // Save
            //[localContext MR_saveToPersistentStoreAndWait];
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    DDLogVerbose(@"doodleStore: updated doodle: %@", imageUrl);
                } else if (error) {
                    DDLogVerbose(@"doodleStore: error updating doodle: %@ - %@", imageUrl, [error localizedDescription]);
                }
            }];
        }
    }
}

+ (void)deleteDoodleFromDatabaseWithUrl:(NSString *)imageUrl
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // NOTE - we're not checking if doodle is in database first (as  the checkIfImageNeedsUpdate method does),
    // we're doing that before calling this method, just so it's a bit more clear what we're doing in the fetchDoodleData method
    
    KJRandomImage *doodleToDelete = [KJRandomImage MR_findFirstByAttribute:@"imageUrl" withValue:imageUrl inContext:localContext];
    
    if (doodleToDelete) {
        // Delete object
        [doodleToDelete MR_deleteInContext:localContext];
        
        // Save
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogVerbose(@"doodleStore: deleted doodle");
            } else if (error) {
                DDLogError(@"doodleStore: error deleting doodle: %@", [error localizedDescription]);
            }
        }];
    }
}

+ (void)fetchDoodleData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"doodleStore: fetching doodle data ..");
        
        // Setup query
        PFQuery *randomQuery = [PFQuery queryWithClassName:@"RandomImage"];
        
        // Query all random image urls
        [randomQuery whereKey:kParseImageUrlKey notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [randomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Check if image needs updating
                        [self checkIfImageNeedsUpdateWithId:object[kParseImageIdKey]
                                                description:object[kParseImageDescriptionKey]
                                                        url:object[kParseImageUrlKey]
                                                       date:object[kParseImageDateKey]];
                        
                        // Save Parse object to Core Data
                        [self persistNewRandomImageWithId:object[kParseImageIdKey]
                                              description:object[kParseImageDescriptionKey]
                                                      url:object[kParseImageUrlKey]
                                                     date:object[kParseImageDateKey]];
                    } else {
                        DDLogVerbose(@"doodleStore: doodle not active: %@", object[kParseImageUrlKey]);
                        
                        // Check if doodle exists in database, and delete if so
                        BOOL existInDatabase = [self checkIfRandomImageIsInDatabaseWithImageUrl:object[kParseImageUrlKey]
                                                                                        context:[NSManagedObjectContext MR_contextForCurrentThread]];
                        
                        if (existInDatabase) {
                            DDLogVerbose(@"doodleStore: doodle URL %@ exists in database but is no longer active on server; now removing", object[kParseImageUrlKey]);
                            [self deleteDoodleFromDatabaseWithUrl:object[kParseImageUrlKey]];
                        }
                    }
                }
                // Set randomImagesFetchDone = YES in NSUserDefaults
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRandomImagesFetchDone"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Send NSNotification to say that data fetch is done
                NSString *notificationName = @"KJDoodleDataFetchDidHappen";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
                
                // Prefetch doodles if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [KJDoodleStore prefetchDoodles];
                }
                
            } else {
                // Log details of the failure
                DDLogVerbose(@"doodleStore: error: %@ %@", error, [error userInfo]);
            }
        }];
    });
}

@end
