//
//  UIViewController+KJUtils.m
//  Kidney John
//
//  Created by Josh Lapham on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIViewController+KJUtils.h"

@implementation UIViewController (KJUtils)

#pragma mark - All view controllers

#pragma mark Show fatal error alert method

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

#pragma mark Return 'no network' alert controller

- (UIAlertController *)kj_noNetworkAlertControllerWithNoActions {
    // Init strings for noNetworkAlertView
    NSString *alertTitle = NSLocalizedString(@"No Network", @"Title of error alert displayed when no network connection is available");
    NSString *alertMessage = NSLocalizedString(@"This app requires a network connection", @"Error message displayed when no network connection is available");
    
    // Init alert
    UIAlertController *noNetworkAlertView = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                message:alertMessage
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    return noNetworkAlertView;
}

#pragma mark - Return 'no network' image view

- (UIImageView *)kj_noNetworkImageView {
    // TODO: refactor to UILabel
    UIImage *image = [UIImage imageNamed:@"no-data.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    return imageView;
}

#pragma mark - Video view controllers

#pragma mark Video Detail VC - Show 'no network' alert method

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
    // TODO: review this
    [self presentViewController:noNetworkAlert
                       animated:YES
                     completion:nil];
}

#pragma mark - Favourites view controllers

#pragma mark Favourites List VC - Show 'no favourites' alert method

- (void)kj_showthereAreNoFavouritesAlertWithTitle:(NSString *)viewTitle {
    // Init strings for noFavouritesAlertView
    NSString *alertTitle = NSLocalizedString(@"No Favourites", @"Title of error alert displayed when user hasn't favourited any items");
    // NOTE - using viewTitle parameter, as there could be different values for the title of this view controller
    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"You haven't set any %@ as favourites", @"Message displayed when user hasn't favourited any {items}"), viewTitle];
    NSString *okButtonTitle = NSLocalizedString(@"Okay", @"Title of confirmation button");
    
    // Init alertView
    UIAlertController *noFavouritesAlertView = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                   message:alertMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // Init actions for alertView
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:okButtonTitle
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                           // Go back to previous view controller
                                                           [self.navigationController popViewControllerAnimated:YES];
                                                       }];
    [noFavouritesAlertView addAction:okayAction];
    
    // Show alertView
    [self presentViewController:noFavouritesAlertView
                       animated:YES
                     completion:nil];
}

@end
