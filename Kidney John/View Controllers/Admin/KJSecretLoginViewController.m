//
//  KJSecretLoginViewController.m
//  Kidney John
//
//  Created by jl on 15/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSecretLoginViewController.h"
#import "KJSecretAdminViewController.h"

@interface KJSecretLoginViewController () <PFLogInViewControllerDelegate>

@end

@implementation KJSecretLoginViewController

#pragma mark - dealloc method

- (void)dealloc {
}

#pragma mark - Init method

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set Parse UI properties
        self.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsDismissButton;
        self.logInView.emailAsUsername = YES;
        self.delegate = self;
    }
    
    return self;
}

#pragma mark - View lifecycle methods

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set Parse UI properties
    // NOTE - must be done here according to Parse docs
    // Remove logo
    self.logInView.logo = nil;
}

#pragma mark - PFLogInViewControllerDelegate methods

- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user {
    // Init secret admin VC
    KJSecretAdminViewController *adminViewController = [[KJSecretAdminViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:adminViewController];
    
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

@end
