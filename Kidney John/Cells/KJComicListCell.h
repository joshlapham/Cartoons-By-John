//
//  KJComicListCell.h
//  Kidney John
//
//  Created by Josh Lapham on 12/02/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KJComic;

@interface KJComicListCell : UITableViewCell

// Properties
// TODO: refactor to implementation
@property (weak, nonatomic) IBOutlet UILabel *comicTitle;
@property (weak, nonatomic) IBOutlet UIImageView *comicThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *comicIsNew;

// Methods
+ (NSString *)cellIdentifier;
- (void)configureCellWithData:(KJComic *)cellData;

@end
