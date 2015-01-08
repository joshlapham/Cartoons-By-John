//
//  UIColor+KJColours.m
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIColor+KJColours.h"

@implementation UIColor (KJColours)

// Navbar
+ (UIColor *)kj_navbarColour {
    
    return [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
}

+ (UIColor *)kj_navbarTitleFontShadowColour {
    
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
}

+ (UIColor *)kj_navbarTitleFontColour {
    
    return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
}

@end
