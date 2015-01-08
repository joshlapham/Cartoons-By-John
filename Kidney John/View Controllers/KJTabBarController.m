//
//  KJTabBarController.m
//  Kidney John
//
//  Created by jl on 22/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJTabBarController.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"

@interface KJTabBarController () <UITabBarControllerDelegate>

@end

@implementation KJTabBarController

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set delegate
    self.delegate = self;
    
    // Set tab button titles
    // NOTE: title for More button is set in Storyboard
    [[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Videos", nil)];
    [[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Comix", nil)];
    [[self.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Doodles", nil)];
    
    // Set tab bar background colour
    [[UITabBar appearance] setBarTintColor:[UIColor kj_tabBarBackgroundColour]];
    
    // Set tabbar font and colour when button not selected
    NSDictionary *titleAttributesForNormalState = @{
                                      NSFontAttributeName : [UIFont kj_tabBarFont],
                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                      };
    
    [[UITabBarItem appearance] setTitleTextAttributes:titleAttributesForNormalState
                                             forState:UIControlStateNormal];
    
    // Set tabbar font and colour when button IS selected
    NSDictionary *titleAttributesForSelectedState = @{
                                                      NSFontAttributeName : [UIFont kj_tabBarFont],
                                                      NSForegroundColorAttributeName : [UIColor kj_tabBarItemFontStateSelectedColour]
                                                      };
    
    [[UITabBarItem appearance] setTitleTextAttributes:titleAttributesForSelectedState
                                             forState:UIControlStateSelected];
    
    // Set colour of button icon when selected
    [[UITabBar appearance] setTintColor:[UIColor kj_tabBarItemIconStateSelectedColour]];
}

@end
