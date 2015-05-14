//
//  KJSecretLoginViewController.m
//  Kidney John
//
//  Created by jl on 15/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSecretLoginViewController.h"

@interface KJSecretLoginViewController ()

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
        self.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton;
        self.logInView.emailAsUsername = YES;
    }
    
    return self;
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
