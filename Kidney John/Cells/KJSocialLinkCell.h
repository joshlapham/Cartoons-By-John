//
//  KJSocialLinkCell.h
//  Kidney John
//
//  Created by jl on 26/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJSocialLinkCell : UITableViewCell

// Methods
+ (NSString *)cellIdentifier;
- (void)configureCellWithTitle:(NSString *)title
                      andImage:(UIImage *)image;

@end
