//
//  KJSocialLinkCell.m
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSocialLinkCell.h"
#import "UIFont+KJFonts.h"

@interface KJSocialLinkCell ()

// Properties
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@end

@implementation KJSocialLinkCell

#pragma mark - Awake from NIB (init) method

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Set font
    _titleLabel.font = [UIFont kj_moreViewCellFont];
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

#pragma mark - Getter/setter override methods

- (void)setCellType:(KJSocialLinkCellType)cellType {
    _cellType = cellType;
    
    // Determine cell type and set properties accordingly
    // Favourites
    if (self.cellType == KJSocialLinkCellTypeFavourites) {
        // Fix the look of the Video thumbnail when in tableView
        _iconImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    // Social Link
    else if (self.cellType == KJSocialLinkCellTypeSocialLink) {
        // Give the social icons a bit of opacity to match Favourites icons
        _iconImage.alpha = 0.5;
    }
}

@end
