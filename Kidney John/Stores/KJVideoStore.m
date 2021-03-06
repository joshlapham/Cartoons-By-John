//
//  KJVideoStore.m
//  Kidney John
//
//  Created by jl on 27/02/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJVideoStore.h"
#import "Parse.h"
#import "KJVideo.h"
#import "JPLReachabilityManager.h"
#import "SDWebImagePrefetcher.h"
#import "NSUserDefaults+KJSettings.h"
#import "KJVideo+Methods.h"

// Constants
// Parse keys
NSString * const KJParseKeyVideosId = @"videoId";
NSString * const KJParseKeyVideosName = @"videoName";
NSString * const KJParseKeyVideosDescription = @"videoDescription";
NSString * const KJParseKeyVideosDate = @"date";
NSString * const KJParseKeyVideosDuration = @"videoDuration";

// Constant for NSNotification name
NSString * const KJVideoDataFetchDidHappenNotification = @"KJVideoDataFetchDidHappen";

// Constants for Core Data attributes to find by
static NSString *kVideoAttributeKeyVideoId = @"videoId";
static NSString *kVideoAttributeKeyVideoDate = @"videoDate";

@implementation KJVideoStore {
    BOOL __block changesToVideosWereMade;
    NSArray __block *existingVideosInCoreDataBeforeFetch;
}

#pragma mark - Init method

+ (KJVideoStore *)sharedStore {
    static KJVideoStore *_sharedStore = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJVideoStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Prefetch video thumbnails method

- (void)prefetchVideoThumbnails {
    // Perform fetch for videos in Core Data
    NSArray *resultsArray = [self fetchExistingVideosInCoreData];
    
    // Init array for video thumbnail URLs
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    // Loop over videos in results array to get video ID to form URL
    for (KJVideo *video in resultsArray) {
        NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString,
                               video.videoId];
        NSURL *urlToPrefetch = [NSURL URLWithString:urlString];
        
        // Add URL to array
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls
                                                      progress:nil
                                                     completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
                                                         DDLogVerbose(@"videoStore: prefetched video thumbs count: %lu, skipped: %lu", (unsigned long)finishedCount, (unsigned long)skippedCount);
                                                     }];
}

#pragma mark - Return favourite videos method

// TODO: remove this method once KJFavouritesList VC is updated to use NSFetchedResultsController

// Method to return array of videos that have their attribute isFavourite set to YES.
- (NSArray *)returnFavouritesArray {
    // Init predicate for videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by video date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kVideoAttributeKeyVideoDate
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
        DDLogError(@"videoStore: error fetching favourites: %@", [error localizedDescription]);
        return nil;
    } else {
        return fetchedObjects;
    }
}

#pragma mark - Core Data helper methods

// Method to check if existing videos in Core Data need updating if values from server have changed since last data fetch.
- (void)checkIfVideoNeedsUpdateWithParseObject:(PFObject *)fetchedParseObject {
    // Init strings with values from Parse
    NSString *videoId = fetchedParseObject[KJParseKeyVideosId];
    NSString *videoName = fetchedParseObject[KJParseKeyVideosName];
    NSString *videoDescription = fetchedParseObject[KJParseKeyVideosDescription];
    NSString *videoDate = fetchedParseObject[KJParseKeyVideosDate];
    NSString *videoDuration = fetchedParseObject[KJParseKeyVideosDuration];
    
    // Init fetch request for video matching video ID
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Init predicate for videos matching video ID
    NSPredicate *videoIdPredicate = [NSPredicate predicateWithFormat:@"%@ == %@",
                                     kVideoAttributeKeyVideoId,
                                     videoId];
    
    // Init predicate for videos in pre-fetched videos array
    NSPredicate *prefetchedVideosPredicate = [NSPredicate predicateWithFormat:@"self IN %@", existingVideosInCoreDataBeforeFetch];
    
    // Init final combined predicate to use
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ videoIdPredicate, prefetchedVideosPredicate ]];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Set fetch request properties
    fetchRequest.predicate = predicate;
    fetchRequest.entity = entity;
    
    // Execute the fetch
    NSError *error;
    NSArray *videosInCoreData = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                         error:&error];
    
    // If we found a matching video
    if ([videosInCoreData count] > 0) {
        // Checking videos one at a time, so firstObject works here
        KJVideo *videoToCheck  = [videosInCoreData firstObject];
        
        if (![videoToCheck.videoId isEqualToString:videoId] ||
            ![videoToCheck.videoName isEqualToString:videoName] ||
            ![videoToCheck.videoDescription isEqualToString:videoDescription] ||
            ![videoToCheck.videoDate isEqualToString:videoDate] ||
            ![videoToCheck.videoDuration isEqualToString:videoDuration]) {
            DDLogInfo(@"videoStore: video needs update: %@", videoName);
            
            // Update properties
            videoToCheck.videoId = videoId;
            videoToCheck.videoName = videoName;
            videoToCheck.videoDescription = videoDescription;
            videoToCheck.videoDate = videoDate;
            videoToCheck.videoDuration = videoDuration;
            
            // Set changes to videos were made property so that we can trigger a managedObjectContext save later.
            // This saves us from triggering a save every time we fetch data from the server.
            changesToVideosWereMade = YES;
        }
        else {
            //            DDLogInfo(@"videoStore: video doesn't need update: %@", videoName);
        }
    }
}

// Method to fetch all existing videos in Core Data. We do this before the data fetch to help speed things up.
- (NSArray *)fetchExistingVideosInCoreData {
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init sort descriptor by video date, newest at the top
    // NOTE - we do this just so the prefetchVideoThumbnails method can better prefetch, starting with newest video
    NSSortDescriptor *videoDateDescriptor = [NSSortDescriptor sortDescriptorWithKey:kVideoAttributeKeyVideoDate
                                                                          ascending:NO];
    
    // Init fetch request for only the video ID property of KJVideo
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.sortDescriptors = @[ videoDateDescriptor ];
    
    // Execute the fetch
    NSError *error;
    NSArray *videosInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if (!videosInCoreData) {
        // Handle the error
        return nil;
    }
    else {
        return videosInCoreData;
    }
}

// Method to lazy init existingVideosInCoreDataBeforeFetch array.
- (NSArray *)setupExistingVideosInCoreDataBeforeFetchArray {
    // If we have already init'd, then return existing array
    if (existingVideosInCoreDataBeforeFetch != nil) {
        DDLogInfo(@"videoStore: have already init'd existing videos in Core Data array");
        return existingVideosInCoreDataBeforeFetch;
    }
    
    // Init array with fetchExistingVideosInCoreData method
    existingVideosInCoreDataBeforeFetch = [self fetchExistingVideosInCoreData];
    
    return existingVideosInCoreDataBeforeFetch;
}

// Method to get all video ID strings that exist in Core Data. This helps as we don't have to init a fetch request every time we want to see if something exists in Core Data; we can just check if a video ID exists in the array returned by this method.
- (NSArray *)alreadyFetchedVideoIdsArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request for only the video ID property of KJVideo
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[ kVideoAttributeKeyVideoId ];
    
    // Init predicate for pre-fetched existing videos in Core Data array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", existingVideosInCoreDataBeforeFetch];
    request.predicate = predicate;
    
    // Init array for video ID strings
    NSMutableArray *videoIdStrings = [NSMutableArray new];
    
    // Execute the fetch
    NSError *error;
    NSArray *videosInCoreData = [self.managedObjectContext executeFetchRequest:request
                                                                         error:&error];
    
    if (videosInCoreData == nil) {
        // Handle the error
        return nil;
    }
    else {
        // Get video ID strings
        for (NSDictionary *dict in videosInCoreData) {
            NSString *videoId = [dict valueForKey:kVideoAttributeKeyVideoId];
            [videoIdStrings addObject:videoId];
        }
    }
    
    return [videoIdStrings copy];
}

#pragma mark - Fetch videos from server method

- (void)fetchVideoData {
    // Check connection state
    switch (self.connectionState) {
        case KJVideoStoreStateConnected:
            DDLogInfo(@"videoStore: we're already connected, so aborting fetchVideoData method call");
            return;
            break;
            
        case KJVideoStoreStateConnecting:
            DDLogInfo(@"videoStore: we're already connecting, so aborting fetchVideoData method call");
            return;
            break;
            
        case KJVideoStoreStateDisconnected:
            break;
    }
    
    // Set connection state to CONNECTING
    self.connectionState = KJVideoStoreStateConnecting;
    DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"videoStore: fetching video data ..");
        
        // Setup query with classname on Parse
        PFQuery *query = [PFQuery queryWithClassName:[KJVideo parseClassName]];
        
        // Query all videos
        // TODO: do we really need this?
        [query whereKey:KJParseKeyVideosName
             notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Check for already fetched videos in Core data
        existingVideosInCoreDataBeforeFetch = [self setupExistingVideosInCoreDataBeforeFetchArray];
        
        // Already fetched video ID strings
        NSArray *alreadyFetchedVideoIds = [NSArray arrayWithArray:[self alreadyFetchedVideoIdsArray]];
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Set connection state to CONNECTED
                self.connectionState = KJVideoStoreStateConnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    // Init strings for video ID and name
                    NSString *videoId = object[KJParseKeyVideosId];
                    NSString *videoName = object[KJParseKeyVideosName];
                    
                    // Check if video is set to 'active' on server
                    // TODO: update to use string constants here
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // If video doesn't aleady exist locally in Core Data, then create
                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
                            DDLogInfo(@"videoStore: haven't fetched video %@", videoName);
                            
                            // Init new video
                            KJVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([KJVideo class])
                                                                              inManagedObjectContext:self.managedObjectContext];
                            
                            newVideo.videoId = object[KJParseKeyVideosId];
                            newVideo.videoName = object[KJParseKeyVideosName];
                            newVideo.videoDescription = object[KJParseKeyVideosDescription];
                            newVideo.videoDate = object[KJParseKeyVideosDate];
                            newVideo.videoDuration = object[KJParseKeyVideosDuration];
                            
                            // Set changes to videos were made property so that we can trigger a managedObjectContext save later.
                            // This saves us from triggering a save every time we fetch data from the server.
                            changesToVideosWereMade = YES;
                        }
                        else {
                            //                            DDLogInfo(@"videoStore: already fetched video %@", videoId);
                            
                            // Check if video needs update
                            [self checkIfVideoNeedsUpdateWithParseObject:object];
                        }
                    }
                    
                    // Video is NOT active
                    // Check if it exists locally in Core Data, and delete if so
                    else {
                        //                        DDLogInfo(@"videoStore: video not active: %@", object[@"videoName"]);
                        
                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
                            //                            DDLogInfo(@"videoStore: video %@ isn't active but isn't in database, so it's all good", videoName);
                        }
                        
                        // Video IS in Core Data, so delete
                        else {
                            DDLogInfo(@"videoStore: video %@ isn't active and is in database; deleting now", videoName);
                            
                            // Init fetch request for video to delete
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(%@ == %@)",
                                                      kVideoAttributeKeyVideoId,
                                                      videoId];
                            fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
                                                              inManagedObjectContext:self.managedObjectContext];
                            
                            // Execute the fetch
                            NSError *fetchError;
                            NSArray *itemsToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                                              error:&fetchError];
                            
                            // If we found video to delete ..
                            if ([itemsToDelete count] > 0) {
                                DDLogInfo(@"videoStore: found %lu video to delete", (unsigned long)[itemsToDelete count]);
                                
                                // Delete
                                KJVideo *videoToDelete = [itemsToDelete firstObject];
                                [self.managedObjectContext deleteObject:videoToDelete];
                                
                                // Set changes to videos were made property so that we can trigger a managedObjectContext save later.
                                // This saves us from triggering a save every time we fetch data from the server.
                                changesToVideosWereMade = YES;
                            }
                            else {
                                DDLogError(@"videoStore: failed to find video to delete from Core Data: %@", videoName);
                            }
                        }
                    }
                }
                
                // Save managedObjectContext
                // Only save if we have changes
                if (!changesToVideosWereMade) {
                    DDLogInfo(@"videoStore: no changes to videos were found, so no save managedObjectContext is required");
                }
                
                else {
                    // Changes were made.
                    // This could have been new videos added, existing video info updated, or video deleted from Core Data.
                    NSError *error;
                    if (![self.managedObjectContext save:&error]) {
                        // Handle the error.
                        DDLogError(@"videoStore: failed to save managedObjectContext: %@", [error debugDescription]);
                    }
                    
                    else {
                        DDLogInfo(@"videoStore: saved managedObjectContext");
                    }
                }
                
                // Set firstLoad = YES in NSUserDefaults
                if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
                    [NSUserDefaults kj_setHasFirstVideoFetchCompletedSetting:YES];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                // Post NSNotification that data fetch is done
                [[NSNotificationCenter defaultCenter] postNotificationName:KJVideoDataFetchDidHappenNotification
                                                                    object:nil];
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJVideoStoreStateDisconnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Prefetch video thumbnails if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [self prefetchVideoThumbnails];
                }
            }
            
            else {
                // Log details of the failure
                DDLogError(@"videoStore: error: %@ %@", error, [error userInfo]);
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJVideoStoreStateDisconnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
            }
        }];
    });
}

@end
