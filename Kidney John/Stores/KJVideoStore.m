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

// Constants for Parse object keys
static NSString *kParseVideoIdKey = @"videoId";
static NSString *kParseVideoNameKey = @"videoName";
static NSString *kParseVideoDescriptionKey = @"videoDescription";
static NSString *kParseVideoDateKey = @"date";
static NSString *kParseVideoDurationKey = @"videoDuration";

// Constant for NSNotification name
NSString * const KJVideoDataFetchDidHappenNotification = @"KJVideoDataFetchDidHappen";

@implementation KJVideoStore

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

// TODO: update this to use vanilla Core Data

+ (void)prefetchVideoThumbnails {
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO]];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    for (KJVideo *video in resultsArray) {
        NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString, video.videoId];
        NSURL *urlToPrefetch = [NSURL URLWithString:urlString];
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls progress:nil completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
        DDLogVerbose(@"videoStore: prefetched video thumbs count: %d, skipped: %d", finishedCount, skippedCount);
    }];
}

#pragma mark - Return favourite videos method

// TODO: remove this method once KJFavouritesList VC is updated to use NSFetchedResultsController

- (NSArray *)returnFavouritesArray {
    // Init predicate for videos where isFavourite is TRUE
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavourite != FALSE"];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KJVideo"
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    
    // Set sort descriptor (by video date; newest at the top)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoDate"
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

- (void)checkIfVideoNeedsUpdateWithParseObject:(PFObject *)fetchedParseObject {
    // Init strings with values from Parse
    NSString *videoId = fetchedParseObject[kParseVideoIdKey];
    NSString *videoName = fetchedParseObject[kParseVideoNameKey];
    NSString *videoDescription = fetchedParseObject[kParseVideoDescriptionKey];
    NSString *videoDate = fetchedParseObject[kParseVideoDateKey];
    NSString *videoDuration = fetchedParseObject[kParseVideoDurationKey];
    
    // Init fetch request for video matching video ID
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Init predicate for videos matching video ID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoId == %@", videoId];
    
    // Init entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KJVideo"
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
            
            // NOTE - fetchVideoData method saves managedObjectContext after fetching and checking is complete, no need to do so here
        }
        else {
//            DDLogInfo(@"videoStore: video doesn't need update: %@", videoName);
        }
    }
}

// Method to get all video ID strings that exist in Core Data. This helps as we don't have to init a fetch request every time we want to see if something exists in Core Data; we can just check if a video ID exists in the array returned by this method.
- (NSArray *)alreadyFetchedVideoIdsArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KJVideo"
                                              inManagedObjectContext:self.managedObjectContext];
    
    // Init fetch request for only the video ID property of KJVideo
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"videoId"];
    
    // Init array for video ID strings
    NSMutableArray *videoIdStrings = [NSMutableArray new];
    
    // Execute the fetch
    NSError *error;
    NSArray *videosInCoreData = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (videosInCoreData == nil) {
        // Handle the error
        return nil;
    }
    else {
        // Get video ID strings
        for (NSDictionary *dict in videosInCoreData) {
            NSString *videoId = [dict valueForKey:@"videoId"];
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
    DDLogInfo(@"videoStore: connection state: %u", self.connectionState);
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"videoStore: fetching video data ..");
        
        // Setup query with classname on Parse
        PFQuery *query = [PFQuery queryWithClassName:[KJVideo parseClassName]];
        
        // Query all videos
        [query whereKey:kParseVideoNameKey notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Check for already fetched videos in Core data
        NSArray *alreadyFetchedVideoIds = [NSArray arrayWithArray:[self alreadyFetchedVideoIdsArray]];
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                
                // Set video store connection state to CONNECTED
                self.connectionState = KJVideoStoreStateConnected;
                DDLogInfo(@"videoStore: connection state: %u", self.connectionState);
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    // Init strings for video ID and name
                    NSString *videoId = object[kParseVideoIdKey];
                    NSString *videoName = object[kParseVideoNameKey];
                    
                    // Check if video is set to 'active' on server
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // If video doesn't aleady exist locally in Core Data, then create
                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
                            DDLogInfo(@"videoStore: haven't fetched video %@", videoName);
                            
                            // Init new video
                            KJVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:@"KJVideo"
                                                                              inManagedObjectContext:self.managedObjectContext];
                            
                            newVideo.videoId = object[kParseVideoIdKey];
                            newVideo.videoName = object[kParseVideoNameKey];
                            newVideo.videoDescription = object[kParseVideoDescriptionKey];
                            newVideo.videoDate = object[kParseVideoDateKey];
                            newVideo.videoDuration = object[kParseVideoDurationKey];
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
                        DDLogInfo(@"videoStore: video not active: %@", object[@"videoName"]);
                        
                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
//                            DDLogInfo(@"videoStore: video %@ isn't active but isn't in database, so it's all good", videoName);
                        }
                        
                        // Video IS in Core Data, so delete
                        else {
                            DDLogInfo(@"videoStore: video %@ isn't active and is in database; deleting now", videoName);
                            
                            // Init fetch request for video to delete
                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                            fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(videoId == %@)", videoId];
                            fetchRequest.entity = [NSEntityDescription entityForName:@"KJVideo"
                                                              inManagedObjectContext:self.managedObjectContext];
                            
                            // Execute the fetch
                            NSError *fetchError;
                            NSArray *itemsToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest
                                                                                              error:&fetchError];
                            
                            // If we found video to delete ..
                            if ([itemsToDelete count] > 0) {
                                DDLogInfo(@"videoStore: found %d video to delete", [itemsToDelete count]);
                                
                                // Delete
                                KJVideo *videoToDelete = [itemsToDelete firstObject];
                                [self.managedObjectContext deleteObject:videoToDelete];
                            }
                            else {
                                DDLogError(@"videoStore: failed to find video to delete from Core Data: %@", videoName);
                            }
                        }
                    }
                }
                
                // Save managedObjectContext
                // TODO: only save if we have changes (use property for this)
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    // Handle the error.
                    DDLogError(@"videoStore: failed to save managedObjectContext: %@", [error debugDescription]);
                }
                else {
                    DDLogInfo(@"videoStore: saved managedObjectContext");
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
                DDLogInfo(@"videoStore: connection state: %u", self.connectionState);
                
                // Prefetch video thumbnails if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [KJVideoStore prefetchVideoThumbnails];
                }
            }
            else {
                // Log details of the failure
                DDLogError(@"videoStore: error: %@ %@", error, [error userInfo]);
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJVideoStoreStateDisconnected;
                DDLogInfo(@"videoStore: connection state: %u", self.connectionState);
            }
        }];
    });
}

@end
