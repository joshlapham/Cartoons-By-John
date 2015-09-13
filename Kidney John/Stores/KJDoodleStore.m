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
#import "NSUserDefaults+KJSettings.h"
#import "KJRandomImage+Methods.h"

// Constants for Parse object keys
static NSString *kParseImageIdKey = @"imageId";
static NSString *kParseImageDescriptionKey = @"imageDescription";
static NSString *kParseImageUrlKey = @"imageUrl";
static NSString *kParseImageDateKey = @"date";

// Constant for NSNotification name
NSString * const KJDoodleFetchDidHappenNotification = @"KJDoodleDataFetchDidHappen";

// Constants for Core Data attributes to find by
static NSString *kDoodleAttributeKeyImageId = @"imageId";
static NSString *kDoodleAttributeKeyImageDate = @"imageDate";
static NSString *kDoodleAttributeKeyImageUrl = @"imageUrl";

@implementation KJDoodleStore {
    BOOL __block changesToDoodlesWereMade;
    NSArray __block *existingDoodlesInCoreDataBeforeFetch;
}

#pragma mark Init method

+ (KJDoodleStore *)sharedStore {
    static KJDoodleStore *_sharedStore = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJDoodleStore alloc] init];
    });
    
    return _sharedStore;
}

// TODO: document this method
- (void)prefetchDoodles {
    // Perform fetch for doodles in Core Data
    NSArray *resultsArray = [self fetchExistingDoodlesInCoreData];
    
    // Init array for doodle image URLs
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    // Loop over doodles in results array to get imageURL
    for (KJRandomImage *image in resultsArray) {
        NSURL *urlToPrefetch = [NSURL URLWithString:image.imageUrl];
        
        // Add URL to array
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls
                                                      progress:nil
                                                     completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
                                                         DDLogVerbose(@"doodleStore: prefetched doodles count: %lu, skipped: %lu", (unsigned long)finishedCount, (unsigned long)skippedCount);
                                                     }];
}

// Method to return all doodles.
// NOTE - we need this for KJRandomView, as it isn't using NSFetchedResultsController due to how it loads favourites.
// Method to return array of doodles that have their attribute isFavourite set to YES.
- (NSArray *)returnDoodlesArray {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by doodle date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kDoodleAttributeKeyImageId
                                                                   ascending:YES];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
        DDLogError(@"doodleStore: error fetching doodles: %@", [error localizedDescription]);
        return nil;
    }
    
    else {
        return fetchedObjects;
    }
}

// Method to return array of doodles that have their attribute isFavourite set to YES.
- (NSArray *)returnFavouritesArray {
    // Init predicate for doodles where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by doodle date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kDoodleAttributeKeyImageDate
                                                                   ascending:NO];
    fetchRequest.sortDescriptors = @[ sortDescriptor ];
    
    // Set predicate
    fetchRequest.predicate = predicate;
    
    // Fetch
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext
                               executeFetchRequest:fetchRequest
                               error:&error];
    
    if (fetchedObjects == nil) {
        // Handle the error
        DDLogError(@"doodleStore: error fetching favourites: %@", [error localizedDescription]);
        return nil;
    }
    
    else {
        return fetchedObjects;
    }
}

// Method to check if a doodle exists in Core Data.
- (BOOL)checkIfDoodleExistsLocally:(PFObject *)fetchedParseObject {
    BOOL exists = NO;
    
    // TODO:
    // Check imageId
    // Check imageUrl
    // Check instagramId (this needs to be implemented on data model first)
    
    return exists;
}

// Method to delete all doodles locally from Core Data.
- (void)flushLocalDoodlesInContext:(NSManagedObjectContext *)context {
    DDLogInfo(@"doodleStore: deleting all doodles locally ..");
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:context];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Fetch
    NSError *fetchError;
    NSArray *fetchedObjects = [context
                               executeFetchRequest:fetchRequest
                               error:&fetchError];
    
    if (fetchedObjects.count > 0) {
        DDLogInfo(@"doodleStore: found %lu doodles to flush", (unsigned long)fetchedObjects.count);
        
        for (KJRandomImage *image in fetchedObjects) {
            // Delete
            [context deleteObject:image];
        }
        
        // Save
        NSError *saveError;
        BOOL didSave = [context save:&saveError];
        
        if (!didSave) {
            DDLogError(@"doodleStore: error deleting all doodles locally : %@", saveError.debugDescription);
        }
        
        else {
            DDLogInfo(@"doodleStore: successfully deleted all doodles locally");
        }
    }
    
    // Error fetching objects to flush
    else if (fetchError != nil) {
        DDLogError(@"doodleStore: error finding doodles to flush: %@", [fetchError debugDescription]);
    }
}

// TODO: fix this method; currently fails every time
// Method to check if existing doodles in Core Data need updating if values from server have changed since last data fetch.
- (void)checkIfDoodleNeedsUpdateWithParseObject:(PFObject *)fetchedParseObject {
    // Init strings with values from Parse
    NSString *imageId = fetchedParseObject[kParseImageIdKey];
    NSString *imageUrl = fetchedParseObject[kParseImageUrlKey];
    NSString *imageDescription = fetchedParseObject[kParseImageDescriptionKey];
    NSString *imageDate = fetchedParseObject[kParseImageDateKey];
    
    // Init fetch request for doodle matching image URL
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Init predicate for doodles matching image URL
    NSPredicate *imageUrlPredicate = [NSPredicate predicateWithFormat:@"%@ == %@",
                                      kDoodleAttributeKeyImageUrl,
                                      imageUrl];
    
    // Init predicate for doodles in pre-fetched doodles array
    NSPredicate *prefetchedDoodlesPredicate = [NSPredicate predicateWithFormat:@"self IN %@", existingDoodlesInCoreDataBeforeFetch];
    
    // Init final combined predicate to use
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ imageUrlPredicate,
                                                                                   prefetchedDoodlesPredicate ]];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Set fetch request properties
    fetchRequest.predicate = predicate;
    fetchRequest.entity = entity;
    
    // Execute the fetch
    NSError *error;
    NSArray *doodlesInCoreData = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                          error:&error];
    
    // If we found a matching doodle
    if ([doodlesInCoreData count] > 0) {
        // Checking doodles one at a time, so firstObject works here
        KJRandomImage *doodleToCheck  = [doodlesInCoreData firstObject];
        
        if (![doodleToCheck.imageId isEqualToString:imageId] ||
            ![doodleToCheck.imageUrl isEqualToString:imageUrl] ||
            ![doodleToCheck.imageDescription isEqualToString:imageDescription] ||
            ![doodleToCheck.imageDate isEqualToString:imageDate]) {
            DDLogInfo(@"doodleStore: doodle needs update: %@", imageUrl);
            
            // Update properties
            doodleToCheck.imageId = imageId;
            doodleToCheck.imageUrl = imageUrl;
            doodleToCheck.imageDescription = imageDescription;
            doodleToCheck.imageDate = imageDate;
            
            // Set changes to doodles were made property so that we can trigger a managedObjectContext save later.
            // This saves us from triggering a save every time we fetch data from the server.
            changesToDoodlesWereMade = YES;
        }
        
        else {
            DDLogInfo(@"doodleStore: doodle doesn't need update: %@", imageUrl);
        }
    }
    
    // TODO: testing
    else {
        DDLogVerbose(@"%s - NO DOODLES IN CORE DATA FETCH", __func__);
    }
}

// Method to fetch all existing doodles in Core Data. We do this before the data fetch to help speed things up.
- (NSArray *)fetchExistingDoodlesInCoreData {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    
    // Execute the fetch
    NSError *error;
    NSArray *doodlesInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                          error:&error];
    
    // TODO: refactor to use best practice fetch syntax for better error checking
    
    if (!doodlesInCoreData) {
        return nil;
    }
    
    else {
        return doodlesInCoreData;
    }
}

// Method to lazy init existingDoodlesInCoreDataBeforeFetch array.
- (NSArray *)setupExistingDoodlesInCoreDataBeforeFetchArray {
    // If we have already init'd, then return existing array
    if (existingDoodlesInCoreDataBeforeFetch != nil) {
        DDLogInfo(@"doodleStore: have already init'd existing doodles in Core Data array");
        return existingDoodlesInCoreDataBeforeFetch;
    }
    
    // Init array with fetchExistingDoodlesInCoreData method
    existingDoodlesInCoreDataBeforeFetch = [self fetchExistingDoodlesInCoreData];
    
    return existingDoodlesInCoreDataBeforeFetch;
}

// Method to get all image URL strings that exist in Core Data. This helps as we don't have to init a fetch request every time we want to see if something exists in Core Data; we can just check if an image URL exists in the array returned by this method.
- (NSArray *)alreadyFetchedImageUrlsArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request for only the image URL property of KJRandomImage
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[ kDoodleAttributeKeyImageUrl ];
    
    // Init predicate for pre-fetched existing doodles in Core Data array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", existingDoodlesInCoreDataBeforeFetch];
    request.predicate = predicate;
    
    // Init array for image URL strings
    NSMutableArray *imageUrlStrings = [NSMutableArray new];
    
    // Execute the fetch
    NSError *error;
    NSArray *doodlesInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                          error:&error];
    
    if (doodlesInCoreData == nil) {
        // Handle the error
        return nil;
    }
    
    else {
        // Get image URL strings
        for (NSDictionary *dict in doodlesInCoreData) {
            NSString *imageUrl = [dict valueForKey:kDoodleAttributeKeyImageUrl];
            [imageUrlStrings addObject:imageUrl];
        }
    }
    
    return [imageUrlStrings copy];
}

// TODO: document this method
- (void)fetchDoodleData {
    // Check connection state
    switch (self.connectionState) {
        case KJDoodleStoreStateConnected:
            DDLogInfo(@"doodleStore: we're already connected, so aborting fetchDoodleData method call");
            return;
            break;
            
        case KJDoodleStoreStateConnecting:
            DDLogInfo(@"doodleStore: we're already connecting, so aborting fetchDoodleData method call");
            return;
            break;
            
        case KJDoodleStoreStateDisconnected:
            break;
    }
    
    // Set connection state to CONNECTING
    self.connectionState = KJDoodleStoreStateConnecting;
    DDLogInfo(@"doodleStore: connection state: %lu", (unsigned long)self.connectionState);
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"doodleStore: fetching doodle data ..");
        
        // Setup query
        PFQuery *randomQuery = [PFQuery queryWithClassName:[KJRandomImage parseClassName]];
        
        // Query all random image urls
        [randomQuery whereKey:kParseImageUrlKey notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Check for already fetched doodles in Core Data
        existingDoodlesInCoreDataBeforeFetch = [self setupExistingDoodlesInCoreDataBeforeFetchArray];
        
        // Already fetched image URL strings
        NSArray *alreadyFetchedImageUrls = [NSArray arrayWithArray:[self alreadyFetchedImageUrlsArray]];
        
        // Start query with block
        [randomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Set connection state to CONNECTED
                self.connectionState = KJDoodleStoreStateConnected;
                DDLogInfo(@"doodleStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    // Init string for image URL
                    NSString *imageUrl = object[kParseImageUrlKey];
                    
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        
                        // If doodle doesn't aleady exist locally in Core Data, then create
                        if (![alreadyFetchedImageUrls containsObject:imageUrl]) {
                            DDLogInfo(@"doodleStore: haven't fetched doodle %@", imageUrl);
                            
                            // Init new doodle
                            KJRandomImage *newDoodle = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([KJRandomImage class])
                                                                                     inManagedObjectContext:self.managedObjectContext];
                            
                            newDoodle.imageId = object[kParseImageIdKey];
                            newDoodle.imageUrl = object[kParseImageUrlKey];
                            newDoodle.imageDescription = object[kParseImageDescriptionKey];
                            newDoodle.imageDate = object[kParseImageDateKey];
                            
                            // Set changes to doodles were made property so that we can trigger a managedObjectContext save later.
                            // This saves us from triggering a save every time we fetch data from the server.
                            changesToDoodlesWereMade = YES;
                        }
                        
                        else {
                            DDLogInfo(@"doodleStore: already fetched doodle %@", imageUrl);
                            
                            // Check if doodle needs update
                            [self checkIfDoodleNeedsUpdateWithParseObject:object];
                        }
                    }
                    
                    // Doodle is NOT active
                    // Check if it exists locally in Core Data, and delete if so
                    else {
                        DDLogInfo(@"doodleStore: doodle not active: %@", object[kParseImageUrlKey]);
                        
                        if (![alreadyFetchedImageUrls containsObject:imageUrl]) {
                            DDLogInfo(@"doodleStore: doodle %@ isn't active but isn't in database, so it's all good", imageUrl);
                        }
                        
                        // Doodle IS in Core Data, so delete
                        else {
                            DDLogInfo(@"doodleStore: doodle %@ isn't active and is in database; deleting now", imageUrl);
                            
                            // Init fetch request for Doodle to delete
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            fetchRequest.predicate = [NSPredicate predicateWithFormat: @"%@ == %@",
                                                      kDoodleAttributeKeyImageUrl,
                                                      imageUrl];
                            fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([KJRandomImage class])
                                                              inManagedObjectContext:self.managedObjectContext];
                            
                            // Execute the fetch
                            NSError *fetchError;
                            NSArray *itemsToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                                              error:&fetchError];
                            
                            // If we found doodle to delete ..
                            if ([itemsToDelete count] > 0) {
                                DDLogInfo(@"doodleStore: found %lu doodle to delete", (unsigned long)[itemsToDelete count]);
                                
                                // Delete
                                KJRandomImage *doodleToDelete = [itemsToDelete firstObject];
                                [self.managedObjectContext deleteObject:doodleToDelete];
                                
                                // Set changes to doodles were made property so that we can trigger a managedObjectContext save later.
                                // This saves us from triggering a save every time we fetch data from the server.
                                changesToDoodlesWereMade = YES;
                            }
                            
                            else {
                                DDLogError(@"doodleStore: failed to find doodle to delete from Core Data: %@", imageUrl);
                                
                                if (fetchError != nil) {
                                    DDLogError(@"doodleStore: failed to delete error : %@", fetchError.debugDescription);
                                }
                            }
                        }
                    }
                }
                
                // Save managedObjectContext
                // Only save if we have changes
                if (!changesToDoodlesWereMade) {
                    DDLogInfo(@"doodleStore: no changes to doodles were found, so no save managedObjectContext is required");
                }
                
                else {
                    // Changes were made.
                    // This could have been new doodles added, existing doodle info updated, or doodle deleted from Core Data.
                    NSError *error;
                    if (![self.managedObjectContext save:&error]) {
                        // Handle the error.
                        DDLogError(@"doodleStore: failed to save managedObjectContext: %@", [error debugDescription]);
                    }
                    else {
                        DDLogInfo(@"doodleStore: saved managedObjectContext");
                    }
                }
                
                // Set first fetch = YES in NSUserDefaults
                if (![NSUserDefaults kj_hasFirstDoodleFetchCompletedSetting]) {
                    [NSUserDefaults kj_setHasFirstDoodleFetchCompletedSetting:YES];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                // Send NSNotification to say that data fetch is done
                [[NSNotificationCenter defaultCenter] postNotificationName:KJDoodleFetchDidHappenNotification
                                                                    object:nil];
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJDoodleStoreStateDisconnected;
                DDLogInfo(@"doodleStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Prefetch doodles if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [self prefetchDoodles];
                }
            }
            
            else {
                // Log details of the failure
                DDLogError(@"doodleStore: error: %@ %@", error, [error userInfo]);
                // Set connection state to DISCONNECTED
                self.connectionState = KJDoodleStoreStateDisconnected;
                DDLogInfo(@"doodleStore: connection state: %lu", (unsigned long)self.connectionState);
            }
        }];
    });
}

@end
