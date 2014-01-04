//
//  KJTabBarController.m
//  Kidney John
//
//  Created by jl on 22/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJTabBarController.h"

@interface KJTabBarController () <UITabBarControllerDelegate>

@end

@implementation KJTabBarController

#pragma mark - UITabBarController delegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"TABBAR: did select view: %@", [viewController class]);
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    // Set tabbar background colour to #003366
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1]];
    
    // Set tabbar font
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"JohnRoderickPaine" size:20.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

@end
