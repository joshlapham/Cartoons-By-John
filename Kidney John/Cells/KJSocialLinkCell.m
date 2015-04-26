//
//  KJSocialLinkCell.m
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSocialLinkCell.h"

@interface KJSocialLinkCell ()

// Properties
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@end

@implementation KJSocialLinkCell

#pragma mark - Awake from NIB (init) method

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Cell identifier method

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self.class);
}

#pragma mark - Configure cell method

- (void)configureCellWithTitle:(NSString *)title
                      andImage:(UIImage *)image {
    // Set cell labels
    _titleLabel.text = title;
    _iconImage.image = image;
}

@end
