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
#import "KJVideoFromParse.h"
#import "JPLReachabilityManager.h"
#import "SDWebImagePrefetcher.h"

@implementation KJVideoStore

#pragma mark - Init methods

+ (KJVideoStore *)sharedStore
{
    static KJVideoStore *_sharedStore = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[KJVideoStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Prefetch video thumbnails method

+ (void)prefetchVideoThumbnails
{
    NSArray *resultsArray = [[NSArray alloc] initWithArray:[KJVideo MR_findAllSortedBy:@"videoDate" ascending:NO]];
    NSMutableArray *prefetchUrls = [[NSMutableArray alloc] init];
    
    for (KJVideo *video in resultsArray) {
        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", video.videoId];
        NSURL *urlToPrefetch = [NSURL URLWithString:urlString];
        [prefetchUrls addObject:urlToPrefetch];
    }
    
    // Cache URL for SDWebImage
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:prefetchUrls progress:nil completed:^(NSUInteger finishedCount, NSUInteger skippedCount) {
        DDLogVerbose(@"videoStore: prefetched video thumbs count: %d, skipped: %d", finishedCount, skippedCount);
    }];
}

#pragma mark - Favourites methods

+ (void)updateVideoFavouriteStatus:(NSString *)videoId isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext]) {
        // Video is NOT a favourite
        DDLogVerbose(@"Video is NOT already a favourite, adding now ..");
        
        KJVideo *videoToFavourite = [KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext];
        videoToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        DDLogVerbose(@"videoStore: video not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfVideoIdIsAFavourite:(NSString *)videoId
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext]) {
        KJVideo *videoToFavourite = [KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext];
        if (!videoToFavourite.isFavourite) {
            DDLogVerbose(@"videoStore: video IS NOT a favourite");
            return FALSE;
        } else {
            DDLogVerbose(@"videoStore: video IS a favourite");
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
    
    NSArray *arrayToReturn = [KJVideo MR_findAllWithPredicate:predicate inContext:localContext];
    
    return arrayToReturn;
}

#pragma mark - Core Data methods

+ (BOOL)hasInitialDataFetchHappened
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"firstVideoFetchDone"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)checkIfVideoIsInDatabaseWithVideoId:(NSString *)videoId context:(NSManagedObjectContext *)context
{
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:context]) {
        //DDLogVerbose(@"Yes, video does exist in database");
        return TRUE;
    } else {
        //DDLogVerbose(@"No, video does NOT exist in database");
        return FALSE;
    }
}

+ (void)persistNewVideoWithId:(NSString *)videoId
                         name:(NSString *)videoName
                  description:(NSString *)videoDescription
                         date:(NSString *)videoDate
                   cellHeight:(NSString *)videoCellHeight
                videoDuration:(NSString *)videoDuration
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
        newVideo.videoDuration = videoDuration;
        
        // Save
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogVerbose(@"videoStore: saved new video: %@", videoName);
            } else if (error) {
                DDLogVerbose(@"videoStore: error saving: %@", [error localizedDescription]);
                // TODO: implement alert view on error?
            }
        }];
    }
}

+ (void)checkIfVideoNeedsUpdateWithVideoId:(NSString *)videoId
                                      name:(NSString *)videoName
                               description:(NSString *)videoDescription
                                      date:(NSString *)videoDate
                             videoDuration:(NSString *)videoDuration
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // If video is in database ..
    if ([self checkIfVideoIsInDatabaseWithVideoId:videoId context:localContext]) {
        KJVideo *videoToCheck = [KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext];
        
        // Check if videoToCheck needs updating
        if (![videoToCheck.videoId isEqualToString:videoId] || ![videoToCheck.videoName isEqualToString:videoName] || ![videoToCheck.videoDescription isEqualToString:videoDescription] || ![videoToCheck.videoDate isEqualToString:videoDate] || ![videoToCheck.videoDuration isEqualToString:videoDuration]) {
            // Video needs updating
            DDLogVerbose(@"videoStore: video needs update: %@", videoName);
            
            videoToCheck.videoId = videoId;
            videoToCheck.videoName = videoName;
            videoToCheck.videoDescription = videoDescription;
            videoToCheck.videoDate = videoDate;
            videoToCheck.videoDuration = videoDuration;
            
            // Save
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    DDLogVerbose(@"videoStore: updated video: %@", videoName);
                } else if (error) {
                    DDLogVerbose(@"videoStore: error updating video: %@ - %@", videoName, [error localizedDescription]);
                }
            }];
        }
    }
}

+ (void)fetchVideoData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"videoStore: fetching video data ..");
        
        // Setup query
        PFQuery *query = [KJVideoFromParse query];
        
        // Query all videos
        [query whereKey:@"videoName" notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    if ([object[@"is_active"] isEqual:@"1"]) {
                        // Check if video needs update
                        // TODO: review this, maybe call after firstFetchHasHappened from NSUserDefaults?
                        [self checkIfVideoNeedsUpdateWithVideoId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] videoDuration:object[@"videoDuration"]];
                        
                        // Save Parse object to Core Data
                        [self persistNewVideoWithId:object[@"videoId"] name:object[@"videoName"] description:object[@"videoDescription"] date:object[@"date"] cellHeight:object[@"cellHeight"] videoDuration:object[@"videoDuration"]];
                    } else {
                        DDLogVerbose(@"videoStore: video not active: %@", object[@"videoName"]);
                    }
                }
                // Set firstLoad = YES in NSUserDefaults
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstVideoFetchDone"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Post NSNotification that data fetch is done
                NSString *notificationName = @"KJVideoDataFetchDidHappen";
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
                
                // Prefetch video thumbnails if on Wifi
                if ([JPLReachabilityManager isReachableViaWiFi]) {
                    [KJVideoStore prefetchVideoThumbnails];
                }
                
            } else {
                // Log details of the failure
                DDLogVerbose(@"videoStore: error: %@ %@", error, [error userInfo]);
            }
        }];
    });
}

@end
