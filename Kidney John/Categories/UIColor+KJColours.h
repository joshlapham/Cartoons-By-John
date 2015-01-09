//
//  UIColor+KJColours.h
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (KJColours)

// Navbar
+ (UIColor *)kj_navbarColour;
+ (UIColor *)kj_navbarTitleFontShadowColour;
+ (UIColor *)kj_navbarTitleFontColour;

// Tab bar
+ (UIColor *)kj_tabBarBackgroundColour;
+ (UIColor *)kj_tabBarItemFontStateNormalColour;
+ (UIColor *)kj_tabBarItemFontStateSelectedColour;
+ (UIColor *)kj_tabBarItemIconStateNormalColour;
+ (UIColor *)kj_tabBarItemIconStateSelectedColour;

// Videos
+ (UIColor *)kj_videoDurationTextColour;
+ (UIColor *)kj_newVideoLabelColour;

// 'More' view
+ (UIColor *)kj_moreViewSectionTextColour;

@end
