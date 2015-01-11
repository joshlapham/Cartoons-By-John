//
//  UIFont+KJFonts.m
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIFont+KJFonts.h"
#import "UIFontDescriptor+JohnRoderickPaine.h"

@implementation UIFont (KJFonts)

// Navbar
+ (UIFont *)kj_navbarFont {
    return [self kj_kidneyJohnFontOfSize:21];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleHeadline] size: 0];
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
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleHeadline] size: 0];
}

+ (UIFont *)kj_videoDurationFont {
    return [self kj_kidneyJohnFontOfSize:18];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size: 0];
}

+ (UIFont *)kj_videoNewLabelFont {
    return [self kj_kidneyJohnFontOfSize:12];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleCaption2] size: 0];
}

+ (UIFont *)kj_videoSearchBarFont {
    return [self kj_kidneyJohnFontOfSize:16];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleBody] size: 0];
}

// 'More' view
+ (UIFont *)kj_sectionHeaderFont {
    return [self kj_kidneyJohnFontOfSize:17];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleCaption1] size: 0];
}

+ (UIFont *)kj_moreViewCellFont {
    return [self kj_kidneyJohnFontOfSize:20];
//    return [UIFont fontWithDescriptor:[UIFontDescriptor preferredJohnRoderickPaineFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size: 0];
}

// Private methods
+ (UIFont *)kj_kidneyJohnFontOfSize:(NSInteger)size {
    return [UIFont fontWithName:@"JohnRoderickPaine" size:size];
}

@end
