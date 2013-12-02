//
//  KJVideo.h
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@interface KJVideo : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *videoId;
@property (retain) NSString *videoName;
@property (retain) NSString *videoDescription;

@end
