//
//  KJVideoViewController.m
//  Kidney John
//
//  Created by jl on 18/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoViewController.h"
#import "KJVideoFavouriteActivity.h"
#import "KJVideo.h"

// Constants
// YouTube video URL for social sharing
static NSString *kYouTubeVideoUrlForSharing = @"https://www.youtube.com/watch?v=%@";

@interface KJVideoViewController ()

@end

@implementation KJVideoViewController

#pragma mark - viewDid methods

// Overriding so we can add Action button to navbar.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init action button in top right hand corner
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(showActivityView)];
}

#pragma mark - UIActivityView methods

// Method to handle Action button tap.
- (void)showActivityView {
    // Init UIActivity
    KJVideoFavouriteActivity *favouriteActivity = [[KJVideoFavouriteActivity alloc] initWithVideo:self.chosenVideo];
    
    // Init URL for UIActivity (for social sharing)
    NSURL *activityUrl = [NSURL URLWithString:[NSString stringWithFormat:kYouTubeVideoUrlForSharing, self.chosenVideo.videoId]];
    
    // Init view controller for UIActivity
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[activityUrl]
                                                                             applicationActivities:@[favouriteActivity]];
    
    // Show UIActivity
    [self.navigationController presentViewController:activityVC
                                            animated:YES
                                          completion:nil];
}

@end
