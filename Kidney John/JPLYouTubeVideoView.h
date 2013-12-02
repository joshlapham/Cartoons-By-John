//
//  JPLYouTubeVideoView.h
//  Kidney John
//
//  Created by jl on 13/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPLYouTubeListView.h"

@interface JPLYouTubeVideoView : UIViewController

@property (nonatomic, strong) NSString *videoIdFromList;
@property (nonatomic, strong) NSString *videoTitleFromList;
@property (nonatomic, strong) NSString *videoDescriptionFromList;
@property (nonatomic, strong) NSString *videoDurationFromList;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleField;
@property (weak, nonatomic) IBOutlet UILabel *videoDescriptionField;

@end
