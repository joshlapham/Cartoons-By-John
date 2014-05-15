//
//  KJVideoFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 5/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJVideoFavouriteActivity.h"
#import "KJVideoStore.h"

@implementation KJVideoFavouriteActivity {
    NSString *titleOfActivity;
    NSString *idOfVideo;
    BOOL addOrNot;
}

- (id)initWithActivityTitle:(NSString *)activityTitle andVideoId:(NSString *)videoId
{
    self = [super init];
    
    if (self) {
        titleOfActivity = activityTitle;
        idOfVideo = videoId;
    }
    return self;
}

- (NSString *)activityType
{
    return @"com.joshlapham.Kidney-John favourite video";
}

- (NSString *)activityTitle
{
    return titleOfActivity;
}

- (UIImage *)activityImage
{
    if ([KJVideoStore checkIfVideoIdIsAFavourite:idOfVideo]) {
        return [UIImage imageNamed:@"remove-from-fav.png"];
    } else {
        return [UIImage imageNamed:@"add-to-fav.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    // Check if video is a favourite and update accordingly
    if (![KJVideoStore checkIfVideoIdIsAFavourite:idOfVideo]) {
        [KJVideoStore updateVideoFavouriteStatus:idOfVideo isFavourite:YES];
    } else {
        [KJVideoStore updateVideoFavouriteStatus:idOfVideo isFavourite:NO];
    }
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    [self activityDidFinish:YES];
}

@end
