//
//  KJComicListCell.h
//  Kidney John
//
//  Created by Josh Lapham on 12/02/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJComicListCell : UITableViewCell

// Properties
@property (weak, nonatomic) IBOutlet UILabel *comicTitle;
@property (weak, nonatomic) IBOutlet UIImageView *comicThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *comicIsNew;

// Methods
+ (NSString *)cellIdentifier;

@end