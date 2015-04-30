//
//  KJBaseTableViewCell.h
//  Kidney John
//
//  Created by Josh Lapham on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJBaseTableViewCell : UITableViewCell

// Methods
+ (NSString *)cellIdentifier;
- (void)configureCellWithData:(id)data;

@end
