//
//  KJComicGalleryView.m
//  Kidney John
//
//  Created by jl on 29/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicGalleryView.h"
#import "MWPhotoBrowser.h"
#import "Models/KJComic.h"

@interface KJComicGalleryView () <MWPhotoBrowserDelegate, UIActionSheetDelegate>

@end

@implementation KJComicGalleryView {
    NSArray *comicResults;
    NSMutableArray *comicThumbResults;
    NSMutableArray *comicsForBrowser;
    MWPhotoBrowser *browser;
}

#pragma mark Set up browser methods

- (void)setupComicsBrowser
{
    NSLog(@"Setting up comics browser gallery ...");
    
    // Create browser
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.startOnGrid = YES;
    browser.zoomPhotosToFill = YES;
    //[browser setCurrentPhotoIndex:0];
    
    [self fetchComicsForBrowser];
}

- (void)fetchComicsForBrowser
{
    NSLog(@"Fetching comics for browser ...");
    
    // Init comics array with results from Core Data
    comicResults = [[NSArray alloc] init];
    comicResults = [KJComic MR_findAll];
    comicsForBrowser = [[NSMutableArray alloc] init];
    
    for (KJComic *comic in comicResults) {
        // NOTE - using thumbnails for now
        // would have to check filepath for full-size comics
        // refer to KJComicListView for filepath checking
        [comicsForBrowser addObject:[MWPhoto photoWithImage:[UIImage imageWithData:comic.comicThumbData]]];
        NSLog(@"comic file name: %@", comic.comicFileName);
    }
    
    NSLog(@"comicsForBrowser array count: %lu", (unsigned long)[comicsForBrowser count]);
    
    [self reloadBrowserDataAndPresentBrowser];
    
    // TODO:
    // send a notification once fetch is complete
    // in that notification selector method, call reloadBrowserDataAndPresentBrowser
}

- (void)reloadBrowserDataAndPresentBrowser
{
    NSLog(@"now reloading browser data ...");
    
    [browser reloadData];
    
    // Present browser
    [self addChildViewController:browser];
    [[self view] addSubview:[browser view]];
    [browser didMoveToParentViewController:self];
}

#pragma mark MWPhotoBrowser delegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    // return comics array count
    return comicsForBrowser.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < comicsForBrowser.count) {
        return [comicsForBrowser objectAtIndex:index];
    } else {
        return nil;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < comicsForBrowser.count) {
        return [comicsForBrowser objectAtIndex:index];
    } else {
        return nil;
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index
{
    // Init strings for buttons
    NSString *favouritesString = @"";
    //NSString *other2 = @"Share on Facebook";
    //NSString *other3 = @"Share on Twitter";
    NSString *cancelTitle = @"Cancel";
    //NSString *actionSheetTitle = @"Action";
    //NSString *destructiveTitle = @"Destructive button";
    
    // Set Favourites button text accordingly
    // NOTE - this needs to be reviewed
    // Current just setting this to 'Add to Favourites' for testing purposes
//    if (![self checkIfComicIsAFavourite:titleFromList]) {
//        favouritesString = @"Add to Favourites";
//    } else {
//        favouritesString = @"Remove from Favourites";
//    }
    favouritesString = @"Add to Favourites";
    
    // Init action sheet with Favourites and Share buttons
    // NOTE - no FB/Twitter share is enabled for Comics right now
    //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, other2, other3, nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:favouritesString, nil];
    
    // Add action sheet to view, taking in consideration the tab bar
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonPressed = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    // NOTE - to be reviewed
    // reused code from another class
    if ([buttonPressed isEqualToString:@"Add to Favourites"]) {
        NSLog(@"ACTION SHEET: add to favourites was pressed");
        //[self updateComicFavouriteStatus:titleFromList isFavourite:YES];
    } else if ([buttonPressed isEqualToString:@"Remove from Favourites"]) {
        NSLog(@"ACTION SHEET: remove from favourites was pressed");
        //[self updateComicFavouriteStatus:titleFromList isFavourite:NO];
    } else if ([buttonPressed isEqualToString:@"Share on Twitter"]) {
        NSLog(@"ACTION SHEET: share on twitter button pressed");
        //[self postToTwitter];
    } else if ([buttonPressed isEqualToString:@"Share on Facebook"]) {
        NSLog(@"ACTION SHEET: share on facebook button pressed");
        //[self postToFacebook];
    }
}

#pragma mark Init methods

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self setupComicsBrowser];
}

@end
