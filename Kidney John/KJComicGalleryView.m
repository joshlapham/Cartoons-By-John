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

@property (nonatomic, strong) NSArray *comicResults;
@property (nonatomic, strong) NSMutableArray *comicThumbResults;
@property (nonatomic, strong) NSMutableArray *comicsForBrowser;
@property (nonatomic, strong) MWPhotoBrowser *browser;

@end

@implementation KJComicGalleryView

@synthesize comicResults, comicThumbResults, comicsForBrowser, browser;

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
}

- (void)fetchComicsForBrowser
{
    NSLog(@"Fetching comics for browser ...");
    
//    KJComic *aComic = [[KJComic alloc] init];
//    MWPhoto *comic = [[MWPhoto alloc] init];
//    comic = [MWPhoto photoWithImage:[UIImage imageWithData:aComic.comicThumbData]];
//    [comicsForBrowser addObject:comic];
    
    // Init comics array with results from Core Data
    comicResults = [NSArray array];
    comicResults = [KJComic MR_findAll];
    
    // send a notification once fetch is complete
    // in that notification selector method, call reloadBrowserDataAndPresentBrowser
}

- (void)reloadBrowserDataAndPresentBrowser
{
    [browser reloadData];
    
    // Present
    [self addChildViewController:self.browser];
    [[self view] addSubview:[self.browser view]];
    [self.browser didMoveToParentViewController:self];
}

#pragma mark MWPhotoBrowser delegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    // return comics array count
    return comicResults.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < comicResults.count) {
        return [comicResults objectAtIndex:index];
    } else {
        return nil;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    // NOTE - change this to the comic thumbs array
    if (index < comicResults.count) {
        return [comicResults objectAtIndex:index];
    } else {
        return nil;
    }
}

#pragma mark Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupComicsBrowser];
}

@end
