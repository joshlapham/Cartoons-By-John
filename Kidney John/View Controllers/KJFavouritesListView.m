//
//  KJFavouritesListView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJFavouritesListView.h"
#import "JPLYouTubeVideoView.h"
#import "KJVideo.h"
#import "KJVideo+Methods.h"
#import "KJComic.h"
#import "KJComic+Methods.h"
#import "KJRandomImage.h"
#import "KJComicDetailView.h"
#import "KJComicStore.h"
#import "KJRandomView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"
#import "KJVideoCell.h"
#import "KJComicListCell.h"
#import "UIViewController+KJUtils.h"

// Constants
// Segue identifiers
static NSString * kSegueIdentifierVideoFavourites = @"favouritesVideoSegue";
static NSString * kSegueIdentifierComicDetailFavourites = @"comicDetailSegueFromFavourites";

// Fallback placeholder for video duration
static NSString * kVideoDurationFallbackString = @"0:30";

@interface KJFavouritesListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation KJFavouritesListView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.titleForView;
    
    // Register cells with tableView
    [self.tableView registerNib:[UINib nibWithNibName:[KJComicListCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[KJComicListCell cellIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[KJVideoCell cellIdentifier] bundle:nil]
         forCellReuseIdentifier:[KJVideoCell cellIdentifier]];
    
    // Set background colour for view
    // Accessibility
    if (UIAccessibilityDarkerSystemColorsEnabled()) {
        self.view.backgroundColor = [UIColor kj_accessibilityDarkenColoursBackgroundColour];
    }
    
    else {
        self.view.backgroundColor = [UIColor kj_viewBackgroundColour];
    }
    
    // Set auto row height for cells
    self.tableView.estimatedRowHeight = 122;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Check for Favourites results
    if ([self.cellResults count] == 0) {
        [self kj_showthereAreNoFavouritesAlertWithTitle:self.titleForView];
    }
}

#pragma mark - UITableView data source delegate methods

// TODO: refactor dataSource into own class

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.cellResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Video cell
    if ([[self.cellResults firstObject] isKindOfClass:[KJVideo class]]) {
        // Init KJVideoCell
        KJVideoCell *videoCell = [tableView dequeueReusableCellWithIdentifier:[KJVideoCell cellIdentifier]
                                                                 forIndexPath:indexPath];
        
        // Init cell data
        KJVideo *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        // Configure cell
        [videoCell configureCellWithData:cellData];
        
        // Return cell
        return videoCell;
    }
    
    // Comic cell
    else if ([[self.cellResults firstObject] isKindOfClass:[KJComic class]]) {
        // Init KJComicListCell
        KJComicListCell *comicCell = [tableView dequeueReusableCellWithIdentifier:[KJComicListCell cellIdentifier]
                                                                     forIndexPath:indexPath];
        
        // Init cell data
        KJComic *cellData = [self.cellResults objectAtIndex:indexPath.row];
        
        // Configure cell
        [comicCell configureCellWithData:cellData];
        
        // Return cell
        return comicCell;
    }
    
    // NOTE - returning nil by default
    return nil;
}

#pragma mark - UITableView delegate methods

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Videos
    if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJVideo class]]) {
        [self performSegueWithIdentifier:kSegueIdentifierVideoFavourites
                                  sender:self];
    }
    
    // Comics
    else if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        [self performSegueWithIdentifier:kSegueIdentifierComicDetailFavourites
                                  sender:self];
    }
}

#pragma mark - Prepare for segue method

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Init index path
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    // Videos
    if ([segue.identifier isEqualToString:kSegueIdentifierVideoFavourites]) {
        JPLYouTubeVideoView *destViewController = segue.destinationViewController;
        KJVideo *cellVideo = [self.cellResults objectAtIndex:indexPath.row];
        destViewController.chosenVideo = cellVideo;
    }
    
    // Comics
    else if ([segue.identifier isEqualToString:kSegueIdentifierComicDetailFavourites]) {
        // Init destination view controller
        KJComicDetailView *destViewController = segue.destinationViewController;
        
        // Init cell data
        KJComic *comicCell = [self.cellResults objectAtIndex:indexPath.row];
        
        // Pass chosen comic to detail view
        destViewController.initialComicToShow = comicCell;
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

@end
