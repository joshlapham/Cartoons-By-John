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
    if ([KJDoodleStore checkIfDoodleIsAFavourite:urlOfImage]) {
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
    if (![KJDoodleStore checkIfDoodleIsAFavourite:urlOfImage]) {
        [KJDoodleStore updateDoodleFavouriteStatus:urlOfImage isFavourite:YES];
    } else {
        [KJDoodleStore updateDoodleFavouriteStatus:urlOfImage isFavourite:NO];
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
