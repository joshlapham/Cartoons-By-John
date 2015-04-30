//
//  KJSocialLinkCell.h
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBaseTableViewCell.h"

// ENUM for cell type
typedef enum : NSUInteger {
    KJSocialLinkCellTypeFavourites,
    KJSocialLinkCellTypeSocialLink,
} KJSocialLinkCellType;

@interface KJSocialLinkCell : KJBaseTableViewCell

// Properties
@property (nonatomic) KJSocialLinkCellType cellType;

// Methods
- (void)configureCellWithTitle:(NSString *)title
                      andImage:(UIImage *)image;

@end
