//
//  UIColor+KJColours.m
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIColor+KJColours.h"
#import "NSUserDefaults+KJSettings.h"

@implementation UIColor (KJColours)

// Standard background colour for all views
+ (UIColor *)kj_viewBackgroundColour {
    return [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
}

// Accessibility
// Standard background colour for all views with 'Darken Colours' accessibility feature enabled
+ (UIColor *)kj_accessibilityDarkenColoursBackgroundColour {
    return [UIColor darkGrayColor];
}

// Navbar
+ (UIColor *)kj_navbarColour {
    return [UIColor colorWithRed:0.48 green:0.73 blue:0.73 alpha:1];
}

+ (UIColor *)kj_navbarTitleFontShadowColour {
    return [UIColor lightGrayColor];
}

+ (UIColor *)kj_navbarTitleFontColour {
    return [UIColor blackColor];
}

// Tab bar
+ (UIColor *)kj_tabBarBackgroundColour {
    return [UIColor colorWithRed:0.48 green:0.73 blue:0.73 alpha:1];
}

+ (UIColor *)kj_tabBarItemFontStateNormalColour {
    return [UIColor whiteColor];
}

+ (UIColor *)kj_tabBarItemFontStateSelectedColour {
    return [UIColor blackColor];
}

+ (UIColor *)kj_tabBarItemIconStateNormalColour {
    return [UIColor whiteColor];
}

+ (UIColor *)kj_tabBarItemIconStateSelectedColour {
    return [UIColor blackColor];
}

// Video cells
+ (UIColor *)kj_videoDurationTextColour {
    return [UIColor grayColor];
}

+ (UIColor *)kj_newVideoLabelColour {
    return [UIColor colorWithRed:92/255.0 green:184/255.0 blue:92/255.0 alpha:1];
}

// 'More' view
+ (UIColor *)kj_moreViewSectionTextColour {
    return [UIColor darkGrayColor];
}

@end
