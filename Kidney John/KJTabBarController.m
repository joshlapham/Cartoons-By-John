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

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    // Set tabbar background colour to #003366
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1]];
    
    // Set tabbar font and colour when button not selected
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"JohnRoderickPaine" size:16.0], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // Set tabbar font and colour when button IS selected
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"JohnRoderickPaine" size:16.0], NSFontAttributeName, [UIColor colorWithRed:0 green:0.9 blue:2.3 alpha:1], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // Set colour of button icon when selected
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:0.9 blue:2.3 alpha:1]];
}

@end
