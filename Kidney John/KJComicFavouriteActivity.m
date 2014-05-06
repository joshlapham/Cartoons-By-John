//
//  KJComicFavouriteActivity.m
//  Kidney John
//
//  Created by jl on 6/05/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "KJComicFavouriteActivity.h"
#import "KJComicStore.h"

@implementation KJComicFavouriteActivity {
    NSString *titleOfActivity;
    NSString *nameOfComic;
}

- (id)initWithActivityTitle:(NSString *)activityTitle andComicName:(NSString *)comicName
{
    self = [super init];
    
    if (self) {
        titleOfActivity = activityTitle;
        nameOfComic = comicName;
    }
    return self;
}

- (NSString *)activityType
{
    return @"com.joshlapham.Kidney-John favourite comic";
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
    
    if ([KJComicStore checkIfComicIsAFavourite:nameOfComic]) {
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
    if (![KJComicStore checkIfComicIsAFavourite:nameOfComic]) {
        [KJComicStore updateComicFavouriteStatus:nameOfComic isFavourite:YES];
    } else {
        [KJComicStore updateComicFavouriteStatus:nameOfComic isFavourite:NO];
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
