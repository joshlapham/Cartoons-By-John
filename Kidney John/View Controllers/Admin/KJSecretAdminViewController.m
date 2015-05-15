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
    
    // Init 'Done' navbar button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(didTapDoneButton:)];
    self.navigationItem.leftBarButtonItem = doneButton;
}

#pragma mark - UIToolbarDelegate methods

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

#pragma mark - Action handler methods

- (IBAction)didTapDoneButton:(id)sender {
    // TODO: fix this
    // Go back to previous view (back to the app)
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
