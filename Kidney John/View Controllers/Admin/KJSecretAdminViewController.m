//
//  KJSecretAdminViewController.m
//  Kidney John
//
//  Created by jl on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSecretAdminViewController.h"

@interface KJSecretAdminViewController () <UIToolbarDelegate>

@end

@implementation KJSecretAdminViewController

#pragma mark - dealloc method

- (void)dealloc {
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prevent segmented control from being hidden
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UIToolbarDelegate methods

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

@end
