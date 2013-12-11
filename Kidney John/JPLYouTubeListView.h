//
//  JPLYouTubeListView.h
//  Kidney John
//
//  Created by jl on 16/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPLYouTubeVideoProtocol.h"

@interface JPLYouTubeListView : UITableViewController <UITableViewDataSource, UITableViewDelegate, JPLYouTubeVideoDelegate>

@property (nonatomic, strong) __block NSMutableArray *videoIdResults;
@property (nonatomic, strong) __block NSMutableArray *videoTitleResults;
@property (nonatomic, strong) __block NSMutableArray *videoDescriptionResults;
@property (nonatomic, strong) __block NSMutableArray *videoThumbnails;
@property (nonatomic, strong) __block NSMutableArray *cellHeights;

- (void)callFetchMethod;

@end
