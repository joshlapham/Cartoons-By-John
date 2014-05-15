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
    if ([KJComicStore checkIfComicIsAFavourite:nameOfComic]) {
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
    // Check if comic is a favourite and update accordingly
    if (![KJComicStore checkIfComicIsAFavourite:nameOfComic]) {
        [KJComicStore updateComicFavouriteStatus:nameOfComic isFavourite:YES];
    } else {
        [KJComicStore updateComicFavouriteStatus:nameOfComic isFavourite:NO];
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
