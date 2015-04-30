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
    NSString *okayButtonTitle = NSLocalizedString(@"Okay", nil);
    
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

@end
