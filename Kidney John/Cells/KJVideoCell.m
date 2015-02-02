//
//  KJVideoCell.m
//  Kidney John
//
//  Created by jl on 2/02/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJVideoCell.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"

@implementation KJVideoCell

#pragma mark - Awake from NIB method

- (void)awakeFromNib {
    // Video name
    self.videoTitle.font = [UIFont kj_videoNameFont];
    self.videoTitle.numberOfLines = 0;
    self.videoTitle.preferredMaxLayoutWidth = 130;
    
    // Video description
    self.videoDescription.font = [UIFont kj_videoDescriptionFont];
    self.videoDescription.textColor = [UIColor kj_videoDurationTextColour];
    self.videoDescription.numberOfLines = 0;
    self.videoDescription.preferredMaxLayoutWidth = 130;
    
    // Video duration
    self.videoDuration.font = [UIFont kj_videoDurationFont];
    self.videoDuration.numberOfLines = 0;
}

#pragma mark - Cell reuse identifer method

+ (NSString *)cellIdentifier {
    return [NSString stringWithFormat:@"%@", self.class];
}

@end
