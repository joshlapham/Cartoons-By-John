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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

@end
