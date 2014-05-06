//
//  KJRandomFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 6/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJRandomFavouriteActivity.h"
#import "KJDoodleStore.h"

@implementation KJRandomFavouriteActivity {
    NSString *titleOfActivity;
    NSString *urlOfImage;
}

- (id)initWithActivityTitle:(NSString *)activityTitle andImageUrl:(NSString *)imageUrl
{
    self = [super init];
    
    if (self) {
        titleOfActivity = activityTitle;
        urlOfImage = imageUrl;
    }
    return self;
}

- (NSString *)activityType
{
    return @"com.joshlapham.Kidney-John favourite doodle";
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
    
    if ([KJDoodleStore checkIfDoodleIsAFavourite:urlOfImage]) {
        return [UIImage imageNamed:@"remove-from-fav.png"];
    } else {
        return [UIImage imageNamed:@"add-to-fav.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    //NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    // Check if comic is a favourite and update accordingly
    if (![KJDoodleStore checkIfDoodleIsAFavourite:urlOfImage]) {
        [KJDoodleStore updateDoodleFavouriteStatus:urlOfImage isFavourite:YES];
    } else {
        [KJDoodleStore updateDoodleFavouriteStatus:urlOfImage isFavourite:NO];
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
