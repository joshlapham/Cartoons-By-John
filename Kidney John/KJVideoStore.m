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

@implementation KJVideoStore

#pragma mark - Favourites methods

+ (void)updateVideoFavouriteStatus:(NSString *)videoId isFavourite:(BOOL)isOrNot
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    // Create a new video in the current context
    //KJVideo *newVideo = [KJVideo MR_createInContext:localContext];
    
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext]) {
        //NSLog(@"Video is NOT already a favourite, adding now ..");
        
        KJVideo *videoToFavourite = [KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext];
        videoToFavourite.isFavourite = isOrNot;
        
        // Save
        [localContext MR_saveToPersistentStoreAndWait];
    } else {
        NSLog(@"videoStore: video not found in database, not adding anything to favourites");
    }
}

+ (BOOL)checkIfVideoIdIsAFavourite:(NSString *)videoId
{
    // Get the local context
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if ([KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext]) {
        KJVideo *videoToFavourite = [KJVideo MR_findFirstByAttribute:@"videoId" withValue:videoId inContext:localContext];
        if (!videoToFavourite.isFavourite) {
            NSLog(@"videoStore: video IS NOT a favourite");
            return FALSE;
        } else {
            NSLog(@"videoStore: video IS a favourite");
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

#pragma mark - Methods

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
        // Thumbnails
        // DISABLED - we are using SDWebImage to cache the YouTube thumbnails
//        NSString *urlString = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", videoId];
//        NSURL *thumbnailUrl = [NSURL URLWithString:urlString];
//        NSData *thumbData = [NSData dataWithContentsOfURL:thumbnailUrl];
//        newVideo.videoThumb = thumbData;
        
        // Save
        //[localContext MR_saveToPersistentStoreAndWait];
        [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"videoStore: saved new video: %@", videoName);
            } else if (error) {
                NSLog(@"videoStore: error saving: %@", [error localizedDescription]);
                // TODO: implement alert view on error?
            }
        }];
    }
}

- (void)checkIfVideoNeedsUpdateWithVideoId:(NSString *)videoId
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
            NSLog(@"videoStore: video needs update: %@", videoName);
            
            videoToCheck.videoId = videoId;
            videoToCheck.videoName = videoName;
            videoToCheck.videoDescription = videoDescription;
            videoToCheck.videoDate = videoDate;
            videoToCheck.videoDuration = videoDuration;
            
            // Save
            //[localContext MR_saveToPersistentStoreAndWait];
            [localContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"videoStore: updated video: %@", videoName);
                } else if (error) {
                    NSLog(@"videoStore: error updating video: %@ - %@", videoName, [error localizedDescription]);
                }
            }];
        }
    }
}

- (void)fetchVideoData
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSLog(@"videoStore: fetching video data ..");
        
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
                // Do something with the found objects
                
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
                        NSLog(@"videoStore: video not active: %@", object[@"videoName"]);
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"videoStore: error: %@ %@", error, [error userInfo]);
            }
            
            // Set firstLoad = YES in NSUserDefaults
            //[[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLoadDone"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *notificationName = @"KJVideoDataFetchDidHappen";
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        }];
    });
}

@end
