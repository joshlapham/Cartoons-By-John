//
//  KJSocialLinkCell.m
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSocialLinkCell.h"

@implementation KJSocialLinkCell

#pragma mark - Awake from NIB (init) method

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSLog(@"AWAKE FROM NIB");
}

#pragma mark - Cell identifier method

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

#pragma mark - Configure cell method

- (void)configureCellWithTitle:(NSString *)title
                      andImage:(UIImage *)image {
    
}

@end
