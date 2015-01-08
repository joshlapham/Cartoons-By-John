//
//  UIFont+KJFonts.m
//  Kidney John
//
//  Created by jl on 8/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIFont+KJFonts.h"

@implementation UIFont (KJFonts)

+ (UIFont *)kj_navbarFont {
    
    return [self kj_kidneyJohnFontOfSize:21];
}

// Private methods
+ (UIFont *)kj_kidneyJohnFontOfSize:(NSInteger)size {
    
    return [UIFont fontWithName:@"JohnRoderickPaine" size:size];
}

@end
