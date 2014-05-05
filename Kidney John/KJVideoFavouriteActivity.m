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
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"placeholder.png"];
    }
    else
    {
        return [UIImage imageNamed:@"placeholder.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    //NSLog(@"%s", __FUNCTION__);
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
    
    //NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    //NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    // This is where you can do anything you want, and is the whole reason for creating a custom
    // UIActivity
    
    [self activityDidFinish:YES];
}

@end
