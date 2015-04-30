//
//  UIViewController+KJUtils.m
//  Kidney John
//
//  Created by Josh Lapham on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIViewController+KJUtils.h"

@implementation UIViewController (KJUtils)

#pragma mark - Show fatal error alert method

- (void)showFatalErrorAlert {
    // Init alert strings
    NSString *alertTitle = NSLocalizedString(@"Error", nil);
    NSString *alertMessage = NSLocalizedString(@"We're sorry, a fatal error occurred. Please try exiting and re-launching the app.", nil);
    NSString *okayButtonTitle = NSLocalizedString(@"Okay", @"Title of confirmation button");
    
    // Init alert
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                        message:alertMessage
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okayButtonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
    
    [errorAlert addAction:okayAction];
    
    // Show alert
    [self presentViewController:errorAlert
                       animated:YES
                     completion:nil];
}

#pragma mark - Video view controllers

#pragma mark Video Detail VC - Show no network alert method

- (void)kj_showErrorIfNoNetworkConnectionForVideoDetailView {
    // Init strings for noNetworkAlert
    NSString *alertTitle = NSLocalizedString(@"No Connection", @"Title of error alert displayed when no network connection is available");
    NSString *alertMessage = NSLocalizedString(@"A network connection is required to watch videos", @"Error message displayed when no network connection is available");
    NSString *okButtonTitle = NSLocalizedString(@"Okay", @"Title of confirmation button");
    
    // Init alertView
    UIAlertController *noNetworkAlert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                            message:alertMessage
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions
    // Okay
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okButtonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           // Go back to video list view
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }];
    
    [noNetworkAlert addAction:okayAction];
    
    // Show alertView
    [self presentViewController:noNetworkAlert
                       animated:YES
                     completion:nil];
}

@end
