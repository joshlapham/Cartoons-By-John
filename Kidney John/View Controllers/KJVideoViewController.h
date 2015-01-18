//
//  KJVideoViewController.h
//  Kidney John
//
//  Created by jl on 18/01/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "PBYouTubeVideoViewController.h"

@class KJVideo;

@interface KJVideoViewController : PBYouTubeVideoViewController

// Properties
@property (nonatomic, strong) KJVideo *chosenVideo;

@end
