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

// Constants
// Modifier for name & description labels max layout width
static CGFloat kMaxLayoutWidthModifier = 195;

@implementation KJVideoCell

#pragma mark - Accessibility methods

- (NSString *)accessibilityLabel {
    NSString *videoTitle = [self.videoTitle accessibilityLabel];
    NSString *videoDescription = [self.videoDescription accessibilityLabel];
    NSString *videoDuration = [self.videoDuration accessibilityLabel];
    
    NSString *accessibilityString = [NSString stringWithFormat:@"Video title: %@, Description: %@, Duration: %@",
                                     videoTitle,
                                     videoDescription,
                                     videoDuration];
    
    return NSLocalizedString(accessibilityString, nil);
}

- (NSString *)accessibilityHint {
    return NSLocalizedString(@"Play video", nil);
}

#pragma mark - Awake from NIB method

- (void)awakeFromNib {
    // TODO: this is hacky!
    // Calculate max layout width for video name & description labels
    CGFloat mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxLayoutWidth = mainScreenWidth - kMaxLayoutWidthModifier;
    
    // Video name
    self.videoTitle.font = [UIFont kj_videoNameFont];
    self.videoTitle.numberOfLines = 0;
    self.videoTitle.preferredMaxLayoutWidth = maxLayoutWidth;
    
    // Video description
    self.videoDescription.font = [UIFont kj_videoDescriptionFont];
    self.videoDescription.textColor = [UIColor kj_videoDurationTextColour];
    self.videoDescription.numberOfLines = 0;
    self.videoDescription.preferredMaxLayoutWidth = maxLayoutWidth;
    
    // Video duration
    self.videoDuration.font = [UIFont kj_videoDurationFont];
    self.videoDuration.numberOfLines = 0;
    
    // New! label
    self.videoIsNew.font = [UIFont kj_videoNewLabelFont];
    self.videoIsNew.textColor = [UIColor whiteColor];
    self.videoIsNew.backgroundColor = [UIColor kj_newVideoLabelColour];
    self.videoIsNew.numberOfLines = 0;
    self.videoIsNew.textAlignment = NSTextAlignmentCenter;
    
    // Make label round
    self.videoIsNew.layer.masksToBounds = YES;
    self.videoIsNew.layer.cornerRadius = self.videoIsNew.frame.size.width / 2;
    
    // Init text
    NSString *labelText = NSLocalizedString(@"New!", @"Text for label that highlights if a video is new");
    self.videoIsNew.text = labelText;
}

#pragma mark - Prepare for reuse method

- (void)prepareForReuse {
    // Set videoIsNew label to hidden, so label won't show every few cells as tableView is scrolled.
    // NOTE - we toggle hidden property in tableView configureCell method.
    self.videoIsNew.hidden = YES;
}

#pragma mark - Cell reuse identifer method

+ (NSString *)cellIdentifier {
    return [NSString stringWithFormat:@"%@", self.class];
}

@end
