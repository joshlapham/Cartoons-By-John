//
//  KJVideoCell.h
//  Kidney John
//
//  Created by jl on 2/02/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJVideoCell : UITableViewCell

// Methods
+ (NSString *)cellIdentifier;

// Properties
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UILabel *videoDescription;
@property (weak, nonatomic) IBOutlet UILabel *videoDuration;
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnail;

@end
