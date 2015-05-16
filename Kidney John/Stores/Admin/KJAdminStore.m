//
//  KJAdminStore.m
//  Kidney John
//
//  Created by Josh Lapham on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJAdminStore.h"
#import "KJVideo.h"
#import "KJVideo+Methods.h"
#import "Parse.h"

// Constants for Parse object keys
static NSString *kParseVideoIdKey = @"videoId";
static NSString *kParseVideoNameKey = @"videoName";
static NSString *kParseVideoDescriptionKey = @"videoDescription";
static NSString *kParseVideoDateKey = @"date";
static NSString *kParseVideoDurationKey = @"videoDuration";

@implementation KJAdminStore

#pragma mark - Init method

+ (instancetype)sharedStore {
    static KJAdminStore *_sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStore = [[KJAdminStore alloc] init];
    });
    
    return _sharedStore;
}

#pragma mark - Fetch videos from server method

- (void)fetchVideoData {
    // Check connection state
    switch (self.connectionState) {
        case KJAdminStoreStateConnected:
            DDLogInfo(@"AdminStore: we're already connected, so aborting fetchVideoData method call");
            return;
            break;
            
        case KJAdminStoreStateConnecting:
            DDLogInfo(@"AdminStore: we're already connecting, so aborting fetchVideoData method call");
            return;
            break;
            
        case KJAdminStoreStateDisconnected:
            break;
    }
    
    // Set connection state to CONNECTING
    self.connectionState = KJAdminStoreStateConnecting;
    DDLogInfo(@"AdminStore: connection state: %lu", (unsigned long)self.connectionState);
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(defaultQueue, ^{
        DDLogVerbose(@"AdminStore: fetching video data ..");
        
        // Setup query with classname on Parse
        PFQuery *query = [PFQuery queryWithClassName:[KJVideo parseClassName]];
        
        // Query all videos
        [query whereKey:kParseVideoNameKey notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Check for already fetched videos in Core data
//        existingVideosInCoreDataBeforeFetch = [self setupExistingVideosInCoreDataBeforeFetchArray];
        
        // Already fetched video ID strings
//        NSArray *alreadyFetchedVideoIds = [NSArray arrayWithArray:[self alreadyFetchedVideoIdsArray]];
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                // Set connection state to CONNECTED
                self.connectionState = KJAdminStoreStateConnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                for (PFObject *object in objects) {
                    // Init strings for video ID and name
                    NSString *videoId = object[kParseVideoIdKey];
                    NSString *videoName = object[kParseVideoNameKey];
                    
//                    // Check if video is set to 'active' on server
//                    if ([object[@"is_active"] isEqual:@"1"]) {
//                        // If video doesn't aleady exist locally in Core Data, then create
//                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
//                            DDLogInfo(@"videoStore: haven't fetched video %@", videoName);
//                            
//                            // Init new video
//                            KJVideo *newVideo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([KJVideo class])
//                                                                              inManagedObjectContext:self.managedObjectContext];
//                            
//                            newVideo.videoId = object[kParseVideoIdKey];
//                            newVideo.videoName = object[kParseVideoNameKey];
//                            newVideo.videoDescription = object[kParseVideoDescriptionKey];
//                            newVideo.videoDate = object[kParseVideoDateKey];
//                            newVideo.videoDuration = object[kParseVideoDurationKey];
//                            
//                            // Set changes to videos were made property so that we can trigger a managedObjectContext save later.
//                            // This saves us from triggering a save every time we fetch data from the server.
//                            changesToVideosWereMade = YES;
//                        }
//                        else {
//                            //                            DDLogInfo(@"videoStore: already fetched video %@", videoId);
//                            
//                            // Check if video needs update
//                            [self checkIfVideoNeedsUpdateWithParseObject:object];
//                        }
//                    }
                    
                    // Video is NOT active
                    // Check if it exists locally in Core Data, and delete if so
//                    else {
//                        //                        DDLogInfo(@"videoStore: video not active: %@", object[@"videoName"]);
//                        
//                        if (![alreadyFetchedVideoIds containsObject:videoId]) {
//                            //                            DDLogInfo(@"videoStore: video %@ isn't active but isn't in database, so it's all good", videoName);
//                        }
//                        
//                        // Video IS in Core Data, so delete
//                        else {
//                            DDLogInfo(@"videoStore: video %@ isn't active and is in database; deleting now", videoName);
//                            
//                            // Init fetch request for video to delete
//                            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//                            fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(%@ == %@)",
//                                                      kVideoAttributeKeyVideoId,
//                                                      videoId];
//                            fetchRequest.entity = [NSEntityDescription entityForName:NSStringFromClass([KJVideo class])
//                                                              inManagedObjectContext:self.managedObjectContext];
//                            
//                            // Execute the fetch
//                            NSError *fetchError;
//                            NSArray *itemsToDelete = [self.managedObjectContext executeFetchRequest:fetchRequest
//                                                                                              error:&fetchError];
//                            
//                            // If we found video to delete ..
//                            if ([itemsToDelete count] > 0) {
//                                DDLogInfo(@"videoStore: found %lu video to delete", (unsigned long)[itemsToDelete count]);
//                                
//                                // Delete
//                                KJVideo *videoToDelete = [itemsToDelete firstObject];
//                                [self.managedObjectContext deleteObject:videoToDelete];
//                                
//                                // Set changes to videos were made property so that we can trigger a managedObjectContext save later.
//                                // This saves us from triggering a save every time we fetch data from the server.
//                                changesToVideosWereMade = YES;
//                            }
//                            else {
//                                DDLogError(@"videoStore: failed to find video to delete from Core Data: %@", videoName);
//                            }
//                        }
//                    }
                }
                
//                // Save managedObjectContext
//                // Only save if we have changes
//                if (!changesToVideosWereMade) {
//                    DDLogInfo(@"videoStore: no changes to videos were found, so no save managedObjectContext is required");
//                }
//                
//                else {
//                    // Changes were made.
//                    // This could have been new videos added, existing video info updated, or video deleted from Core Data.
//                    NSError *error;
//                    if (![self.managedObjectContext save:&error]) {
//                        // Handle the error.
//                        DDLogError(@"videoStore: failed to save managedObjectContext: %@", [error debugDescription]);
//                    }
//                    
//                    else {
//                        DDLogInfo(@"videoStore: saved managedObjectContext");
//                    }
//                }
//                
//                // Set firstLoad = YES in NSUserDefaults
//                if (![NSUserDefaults kj_hasFirstVideoFetchCompletedSetting]) {
//                    [NSUserDefaults kj_setHasFirstVideoFetchCompletedSetting:YES];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//                
//                // Post NSNotification that data fetch is done
//                [[NSNotificationCenter defaultCenter] postNotificationName:KJVideoDataFetchDidHappenNotification
//                                                                    object:nil];
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJAdminStoreStateDisconnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
                
//                // Prefetch video thumbnails if on Wifi
//                if ([JPLReachabilityManager isReachableViaWiFi]) {
//                    [self prefetchVideoThumbnails];
//                }
            }
            
            else {
                // Log details of the failure
                DDLogError(@"videoStore: error: %@ %@", error, [error userInfo]);
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJAdminStoreStateDisconnected;
                DDLogInfo(@"videoStore: connection state: %lu", (unsigned long)self.connectionState);
            }
        }];
    });
}

@end
