//
//  UIFontDescriptor+JohnRoderickPaine.m
//  Kidney John
//
//  Created by jl on 11/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "UIFontDescriptor+JohnRoderickPaine.h"

@implementation UIFontDescriptor (JohnRoderickPaine)

+ (UIFontDescriptor *)preferredJohnRoderickPaineFontDescriptorWithTextStyle:(NSString *)style {
    static dispatch_once_t onceToken;
    static NSDictionary *fontSizeTable;
    dispatch_once(&onceToken, ^{
        fontSizeTable = @{
                          UIFontTextStyleHeadline: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @26,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @25,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @24,
                                  UIContentSizeCategoryAccessibilityLarge: @24,
                                  UIContentSizeCategoryAccessibilityMedium: @23,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @23,
                                  UIContentSizeCategoryExtraExtraLarge: @22,
                                  UIContentSizeCategoryExtraLarge: @21,
                                  UIContentSizeCategoryLarge: @20,
                                  UIContentSizeCategoryMedium: @19,
                                  UIContentSizeCategorySmall: @18,
                                  UIContentSizeCategoryExtraSmall: @17,},
                          
                          UIFontTextStyleSubheadline: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @24,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @23,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @22,
                                  UIContentSizeCategoryAccessibilityLarge: @22,
                                  UIContentSizeCategoryAccessibilityMedium: @21,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @21,
                                  UIContentSizeCategoryExtraExtraLarge: @20,
                                  UIContentSizeCategoryExtraLarge: @19,
                                  UIContentSizeCategoryLarge: @18,
                                  UIContentSizeCategoryMedium: @17,
                                  UIContentSizeCategorySmall: @16,
                                  UIContentSizeCategoryExtraSmall: @15,},
                          
                          UIFontTextStyleBody: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @21,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @20,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @19,
                                  UIContentSizeCategoryAccessibilityLarge: @19,
                                  UIContentSizeCategoryAccessibilityMedium: @18,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @18,
                                  UIContentSizeCategoryExtraExtraLarge: @17,
                                  UIContentSizeCategoryExtraLarge: @16,
                                  UIContentSizeCategoryLarge: @15,
                                  UIContentSizeCategoryMedium: @14,
                                  UIContentSizeCategorySmall: @13,
                                  UIContentSizeCategoryExtraSmall: @12,},
                          
                          UIFontTextStyleCaption1: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @19,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @18,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @17,
                                  UIContentSizeCategoryAccessibilityLarge: @17,
                                  UIContentSizeCategoryAccessibilityMedium: @16,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @16,
                                  UIContentSizeCategoryExtraExtraLarge: @16,
                                  UIContentSizeCategoryExtraLarge: @15,
                                  UIContentSizeCategoryLarge: @14,
                                  UIContentSizeCategoryMedium: @13,
                                  UIContentSizeCategorySmall: @12,
                                  UIContentSizeCategoryExtraSmall: @12,},
                          
                          UIFontTextStyleCaption2: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @18,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @17,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @16,
                                  UIContentSizeCategoryAccessibilityLarge: @16,
                                  UIContentSizeCategoryAccessibilityMedium: @15,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @15,
                                  UIContentSizeCategoryExtraExtraLarge: @14,
                                  UIContentSizeCategoryExtraLarge: @14,
                                  UIContentSizeCategoryLarge: @13,
                                  UIContentSizeCategoryMedium: @12,
                                  UIContentSizeCategorySmall: @12,
                                  UIContentSizeCategoryExtraSmall: @11,},
                          
                          UIFontTextStyleFootnote: @{
                                  UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: @16,
                                  UIContentSizeCategoryAccessibilityExtraExtraLarge: @15,
                                  UIContentSizeCategoryAccessibilityExtraLarge: @14,
                                  UIContentSizeCategoryAccessibilityLarge: @14,
                                  UIContentSizeCategoryAccessibilityMedium: @13,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @13,
                                  UIContentSizeCategoryExtraExtraLarge: @12,
                                  UIContentSizeCategoryExtraLarge: @12,
                                  UIContentSizeCategoryLarge: @11,
                                  UIContentSizeCategoryMedium: @11,
                                  UIContentSizeCategorySmall: @10,
                                  UIContentSizeCategoryExtraSmall: @10,},
                          };
    });
    
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    return [UIFontDescriptor fontDescriptorWithName:[self preferredFontName]
                                               size:((NSNumber *)fontSizeTable[style][contentSize]).floatValue];
}

+ (NSString *)preferredFontName {
    return @"JohnRoderickPaine";
}

@end
