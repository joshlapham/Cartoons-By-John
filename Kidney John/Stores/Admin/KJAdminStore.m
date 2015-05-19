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
#import "KJVideoStore.h"

// Constant for NSNotification name
NSString * const KJAdminStoreVideoDataFetchDidHappenNotification = @"KJAdminStoreVideoDataFetchDidHappen";

@interface KJAdminStore ()

// Properties
@property (nonatomic, strong, readwrite) NSArray *fetchedVideos;

@end

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
        [query whereKey:KJParseKeyVideosName
             notEqualTo:@"LOL"];
        
        // Cache policy
        //query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // Start query with block
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded
                
                // TODO: move this out of this scope (on all stores)
                // Set connection state to CONNECTED
                self.connectionState = KJAdminStoreStateConnected;
                
                DDLogInfo(@"AdminStore: connection state: %lu", (unsigned long)self.connectionState);
                
                // Show network activity monitor
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                
                NSLog(@"%s - GOT VIDEO COUNT : %d", __func__, objects.count);
                
                
                // Set fetched videos array
                self.fetchedVideos = [NSArray arrayWithArray:objects];
                
                //                NSMutableArray *tmpArray = [NSMutableArray new];
                
                //                for (PFObject *object in objects) {
                //                    // Init strings for video ID and name
                //                    NSString *videoId = object[kParseVideoIdKey];
                //                    NSString *videoName = object[kParseVideoNameKey];
                //                    NSString *videoDescription = object[kParseVideoDescriptionKey];
                //                    NSString *videoDuration = object[kParseVideoDurationKey];
                //                    NSString *videoDate = object[kParseVideoDateKey];
                //
                //                    KJVideo *newVideo = [[KJVideo alloc] init];
                //                    newVideo.videoId = videoId;
                //                    newVideo.videoName = videoName;
                //                    newVideo.videoDescription = videoDescription;
                //                    newVideo.videoDuration = videoDuration;
                //                    newVideo.videoDate = videoDate;
                //
                //                    [tmpArray addObject:newVideo];
                //
                //                    // TODO: is_active attribute
                //
                //                    // TODO: improve this
                //                }
                
                // Set fetched videos array
                //                self.fetchedVideos = [NSArray arrayWithArray:tmpArray];
                
                // Post NSNotification that data fetch is done
                [[NSNotificationCenter defaultCenter] postNotificationName:KJAdminStoreVideoDataFetchDidHappenNotification
                                                                    object:nil];
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJAdminStoreStateDisconnected;
                DDLogInfo(@"AdminStore: connection state: %lu", (unsigned long)self.connectionState);
                
                //                // Prefetch video thumbnails if on Wifi
                //                if ([JPLReachabilityManager isReachableViaWiFi]) {
                //                    [self prefetchVideoThumbnails];
                //                }
            }
            
            else {
                // Log details of the failure
                DDLogError(@"AdminStore: error: %@ %@", error, [error userInfo]);
                
                // Set connection state to DISCONNECTED
                self.connectionState = KJAdminStoreStateDisconnected;
                DDLogInfo(@"AdminStore: connection state: %lu", (unsigned long)self.connectionState);
            }
        }];
    });
}

#pragma mark - Getter/setter override methods

- (void)setConnectionState:(KJAdminStoreConnectionState)connectionState {
    _connectionState = connectionState;
    
    NSLog(@"%s", __func__);
    
    // TODO: post notifications depending on connection state
}

@end
