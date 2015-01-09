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

// Navbar
+ (UIColor *)kj_navbarColour {
    
    if (![NSUserDefaults kj_usingVersion2ColourSchemeSetting]) {
        // 'Kidney John' colour (Version 1.0)
        return [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
    } else {
        // 'JohnRodPaine' colour (Version ?)
        return [UIColor colorWithRed:0.48 green:0.73 blue:0.73 alpha:1];
    }
}

+ (UIColor *)kj_navbarTitleFontShadowColour {
    
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
}

+ (UIColor *)kj_navbarTitleFontColour {
    
    return [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
}

// Tab bar
+ (UIColor *)kj_tabBarBackgroundColour {
    
    if (![NSUserDefaults kj_usingVersion2ColourSchemeSetting]) {
        // 'Kidney John' colour (Version 1.0)
        return [UIColor colorWithRed:0 green:0.2 blue:0.4 alpha:1];
    } else {
        // 'JohnRodPaine' colour (Version ?)
        return [UIColor colorWithRed:0.48 green:0.73 blue:0.73 alpha:1];
    }
}

+ (UIColor *)kj_tabBarItemFontStateNormalColour {
    
    return [UIColor whiteColor];
}

+ (UIColor *)kj_tabBarItemFontStateSelectedColour {
    
    if (![NSUserDefaults kj_usingVersion2ColourSchemeSetting]) {
        // 'Kidney John' colour (Version 1.0)
        return [UIColor colorWithRed:0 green:0.9 blue:2.3 alpha:1];
    } else {
        // 'JohnRodPaine' colour (Version ?)
        return [UIColor blackColor];
    }
}

+ (UIColor *)kj_tabBarItemIconStateNormalColour {
    
    if (![NSUserDefaults kj_usingVersion2ColourSchemeSetting]) {
        // 'Kidney John' colour (Version 1.0)
        return [UIColor grayColor];
    } else {
        // 'JohnRodPaine' colour (Version ?)
        return [UIColor whiteColor];
    }
}

+ (UIColor *)kj_tabBarItemIconStateSelectedColour {
    
    if (![NSUserDefaults kj_usingVersion2ColourSchemeSetting]) {
        // 'Kidney John' colour (Version 1.0)
        return [UIColor colorWithRed:0 green:0.9 blue:2.3 alpha:1];
    } else {
        // 'JohnRodPaine' colour (Version ?)
        return [UIColor blackColor];
    }
}

// Videos
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
