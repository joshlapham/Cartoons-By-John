//
//  KJVideoFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 5/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJVideoFavouriteActivity.h"
#import "KJVideoStore.h"
#import "KJVideo.h"
#import <Parse/Parse.h>

// Constants
// Parse Analytics keys
static NSString * kParseAnalyticsKeyEventName = @"videoFavourite";
static NSString * kParseAnalyticsKeyVideoTitle = @"videoTitle";
static NSString * kParseAnalyticsKeyVideoId = @"videoId";
static NSString * kParseAnalyticsKeyVideoIsFavourite = @"isFavourite";

@implementation KJVideoFavouriteActivity {
    NSString *titleOfActivity;
    KJVideo *videoObject;
}

#pragma mark - Init method

- (id)initWithVideo:(KJVideo *)video {
    self = [super init];
    if (self) {
        // Init video object
        videoObject = video;
        
        // Init activity title, depending on favourite status of video
        if (!videoObject.isFavourite) {
            titleOfActivity = NSLocalizedString(@"Add To Favourites", @"Title of button to favourite an item");
        }
        else {
            titleOfActivity = NSLocalizedString(@"Remove From Favourites", @"Title of button to remove an item as a favourite");
        }
    }
    
    return self;
}

#pragma mark - Other methods

- (NSString *)activityType {
    return @"com.joshlapham.Kidney-John favourite video";
}

- (NSString *)activityTitle {
    return titleOfActivity;
}

- (UIImage *)activityImage {
    if (!videoObject.isFavourite) {
        return [UIImage imageNamed:@"add-to-fav.png"];
    }
    else {
        return [UIImage imageNamed:@"remove-from-fav.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    // Toggle favourite status for videoObject
    videoObject.isFavourite = !videoObject.isFavourite;
    
    // Track action with Parse analytics
    NSDictionary *dimensions = @{
                                 kParseAnalyticsKeyVideoTitle : videoObject.videoName,
                                 kParseAnalyticsKeyVideoId : videoObject.videoId,
                                 kParseAnalyticsKeyVideoIsFavourite : videoObject.isFavourite ? @"YES" : @"NO",
                                 };
    
    [PFAnalytics trackEvent:kParseAnalyticsKeyEventName
                 dimensions:dimensions];
    
    // Save managedObjectContext
    NSError *error;
    if (![videoObject.managedObjectContext save:&error]) {
        // TODO: handle the error
        DDLogError(@"Video: failed to save managedObjectContext: %@", [error debugDescription]);
    }
    
    else {
        DDLogInfo(@"Video: saved managedObjectContext");
    }
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
