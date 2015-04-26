//
//  KJSocialLinkCell.h
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

// ENUM for cell type
typedef enum : NSUInteger {
    KJSocialLinkCellTypeFavourites,
    KJSocialLinkCellTypeSocialLink,
} KJSocialLinkCellType;

@interface KJSocialLinkCell : UITableViewCell

// Properties
@property (nonatomic) KJSocialLinkCellType cellType;

// Methods
+ (NSString *)cellIdentifier;
- (void)configureCellWithTitle:(NSString *)title
                      andImage:(UIImage *)image;

@end
