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
#import "KJVideo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KJVideo+Methods.h"

// Constants
// Modifier for name & description labels max layout width
static CGFloat kMaxLayoutWidthModifier = 195;

@interface KJVideoCell ()

// Properties
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation KJVideoCell

#pragma mark - Awake from NIB method

- (void)awakeFromNib {
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

#pragma mark - Configure cell with data method

- (void)configureCellWithData:(id)data {
    // Init cell data
    KJVideo *cellData = (KJVideo *)data;
    
    // Init label text
    // Video name
    self.videoTitle.text = cellData.videoName;
    
    // Video description
    self.videoDescription.text = cellData.videoDescription;
    
    // Check if new video, add 'New!' label if so
    // NOT a new video, so hide label
    if (![self isNewVideo:cellData]) {
        self.videoIsNew.hidden = YES;
    }
    
    // IS a new video, so show label
    else {
        self.videoIsNew.hidden = NO;
    }
    
    // Video duration
    // Placeholder duration
    if (cellData.videoDuration == nil) {
        self.videoDuration.text = @"0:30";
    } else {
        self.videoDuration.text = cellData.videoDuration;
    }
    
    // Init video thumbnail
    NSString *urlString = [NSString stringWithFormat:KJYouTubeVideoThumbnailUrlString, cellData.videoId];
    
    // Check if image is in cache
    if ([[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString]) {
        //DDLogVerbose(@"found image in cache");
    } else {
        //DDLogVerbose(@"no image in cache");
        // TODO: implement fallback if image not in cache
    }
    
    [self.videoThumbnail sd_setImageWithURL:[NSURL URLWithString:urlString]
                           placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                  completed:^(UIImage *cellImage, NSError *error, SDImageCacheType cacheType, NSURL *url) {
                                      if (cellImage && !error) {
                                          DDLogVerbose(@"Videos: fetched video thumbnail image from URL: %@", url);
                                      } else {
                                          DDLogError(@"Videos: error fetching video thumbnail image: %@", [error localizedDescription]);
                                      }
                                  }];
}

#pragma mark - Highlight new videos methods

#pragma mark Check if video is new or not method

- (BOOL)isNewVideo:(KJVideo *)video {
    // Check date of video compared to today's date.
    // If less than two weeks old then we'll class the video as 'new'.
    
    // Init date object from videoDate
    NSDate *videoDate = [[self dateFormatter] dateFromString:video.videoDate];
    
    // Init date object for today's date
    NSDate *todayDate = [NSDate date];
    
    // Get day components (number of days since video date)
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:videoDate
                                                     toDate:todayDate
                                                    options:NO];
    
    // Check if video is less than 14 days old
    if (dateComponents.day < 15) {
        DDLogVerbose(@"Videos: video %@ is new!", video.videoName);
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark Init date formatter method

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter != nil) {
        return _dateFormatter;
    }
    
    // Init date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    return _dateFormatter;
}

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
    return NSLocalizedString(@"Tap to play video", nil);
}

@end
