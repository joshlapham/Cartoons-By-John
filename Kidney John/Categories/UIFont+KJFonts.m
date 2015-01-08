//
//  UIFont+KJFonts.m
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIFont+KJFonts.h"

@implementation UIFont (KJFonts)

// Navbar
+ (UIFont *)kj_navbarFont {
    
    return [self kj_kidneyJohnFontOfSize:21];
}

// Tab bar
+ (UIFont *)kj_tabBarFont {
    
    return [self kj_kidneyJohnFontOfSize:16];
}

// Progress HUD
+ (UIFont *)kj_progressHudFont {
    
    return [self kj_kidneyJohnFontOfSize:20];
}

// Videos
+ (UIFont *)kj_videoNameFont {
    
    return [self kj_kidneyJohnFontOfSize:22];
}

+ (UIFont *)kj_videoDurationFont {
    
    return [self kj_kidneyJohnFontOfSize:18];
}

+ (UIFont *)kj_videoNewLabelFont {
    
    return [self kj_kidneyJohnFontOfSize:12];
}

+ (UIFont *)kj_videoSearchBarFont {
    
    return [self kj_kidneyJohnFontOfSize:16];
}

// 'More' view
+ (UIFont *)kj_sectionHeaderFont {
    
    return [self kj_kidneyJohnFontOfSize:17];
}

+ (UIFont *)kj_moreViewCellFont {
    
    return [self kj_kidneyJohnFontOfSize:20];
}

// Private methods
+ (UIFont *)kj_kidneyJohnFontOfSize:(NSInteger)size {
    
    return [UIFont fontWithName:@"JohnRoderickPaine" size:size];
}

@end
