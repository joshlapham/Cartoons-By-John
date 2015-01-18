//
//  UIFont+KJFonts.h
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFont (KJFonts)

// Navbar
+ (UIFont *)kj_navbarFont;

// Tab bar
+ (UIFont *)kj_tabBarFont;

// Progress HUD
+ (UIFont *)kj_progressHudFont;

// Videos
+ (UIFont *)kj_videoNameFont;
+ (UIFont *)kj_videoDescriptionFont;
+ (UIFont *)kj_videoDurationFont;
+ (UIFont *)kj_videoNewLabelFont;
+ (UIFont *)kj_videoSearchBarFont;

// 'More' view
+ (UIFont *)kj_sectionHeaderFont;
+ (UIFont *)kj_moreViewCellFont;

@end
