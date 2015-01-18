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
#import "UIImage+KJImageUtils.h"

@interface KJTabBarController () <UITabBarControllerDelegate>

@end

@implementation KJTabBarController

#pragma mark - dealloc method

- (void)dealloc {
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - Setup UI method

- (void)setupUI {
    // Set tab bar background colour
    [[UITabBar appearance] setBarTintColor:[UIColor kj_tabBarBackgroundColour]];
    
    // Set tabbar font and colour when button not selected
    NSDictionary *titleAttributesForNormalState = @{
                                                    NSFontAttributeName : [UIFont kj_tabBarFont],
                                                    NSForegroundColorAttributeName : [UIColor kj_tabBarItemFontStateNormalColour]
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
    
    // Set colour of button icons when not selected
    for (UITabBarItem *item in self.tabBar.items) {
        // Use the UIImage category code (KJImageUtils) for the imageWithColor: method
        item.image = [[item.selectedImage imageWithColor:[UIColor kj_tabBarItemIconStateNormalColour]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

#pragma mark - viewDid methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set delegate
    self.delegate = self;
    
    // Set tab button titles
    [[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"Videos", nil)];
    [[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"Comix", nil)];
    [[self.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"Doodles", nil)];
    [[self.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"More", nil)];
    
    // Register for NSNotification if dynamic type font size changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupUI)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // Setup UI
    [self setupUI];
}

@end
