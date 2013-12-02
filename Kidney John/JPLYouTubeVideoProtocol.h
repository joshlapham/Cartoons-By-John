//
//  JPLYouTubeVideoProtocol.h
//  Kidney John
//
//  Created by jl on 25/11/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"
#import "Models/KJVideo.h"

// Delegate definition
@protocol JPLYouTubeVideoDelegate <NSObject>
@optional

- (void)dayOfWeekChosen:(NSString *)withDay;
- (void)updateMap;

@end

@interface JPLYouTubeVideoProtocol : NSObject
{
    // Delegate to respond back
    id <JPLYouTubeVideoDelegate> _delegate;
}

@property (nonatomic, strong) id delegate;

// PFClass for videos
@property (nonatomic, strong) __block NSMutableArray *videosArray;
- (void)updateVideosArrayWithVideo:(KJVideo *)video;

@end
