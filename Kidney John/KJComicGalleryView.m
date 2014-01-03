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

@interface KJComicGalleryView () <MWPhotoBrowserDelegate>

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

#pragma mark Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupComicsBrowser];
}

@end
