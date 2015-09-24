//
//  KJFavouritesListView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJFavouritesListView.h"
#import "KJVideoViewController.h"
#import "KJVideo.h"
#import "KJComic.h"
#import "KJComicDetailView.h"
#import "UIColor+KJColours.h"
#import "KJVideoCell.h"
#import "KJComicListCell.h"
#import "UIViewController+KJUtils.h"
#import "Kidney_John-Swift.h"

@interface KJFavouritesListView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation KJFavouritesListView

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = self.titleForView;
    
    // Register cells with tableView
    [self.tableView registerNib:[UINib nibWithNibName:[KJComicListCell cellIdentifier]
                                               bundle:nil]
         forCellReuseIdentifier:[KJComicListCell cellIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[KJVideoCell cellIdentifier]
                                               bundle:nil]
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
    
    // Remove excess cells from tableView
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
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
        KJVideoViewController *destViewController = [[KJVideoViewController alloc] init];
        KJVideo *cellVideo = [self.cellResults objectAtIndex:indexPath.row];
        destViewController.chosenVideo = cellVideo;
        
        // Push it
        [self.navigationController pushViewController:destViewController
                                             animated:YES];
    }
    
    // Comics
    else if ([[self.cellResults objectAtIndex:indexPath.row] isKindOfClass:[KJComic class]]) {
        // Init from storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ImageStoryboard" bundle:nil];
        SingleImageViewController *destViewController = [storyboard instantiateViewControllerWithIdentifier:@"SingleImageViewController"];
        destViewController.hidesBottomBarWhenPushed = YES;
        
        // Init cell data
        KJComic *cellData = [_cellResults objectAtIndex:indexPath.row];
        
        // Set image
        destViewController.imageToShow = cellData;
        
        // Push it
        [self.navigationController pushViewController:destViewController
                                             animated:YES];
    }
}

@end
