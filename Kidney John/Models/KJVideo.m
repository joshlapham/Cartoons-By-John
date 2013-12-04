//
//  KJVideo.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJVideo.h"
#import "PFObject+Subclass.h"

@implementation KJVideo

+ (NSString *)parseClassName
{
    return @"Video";
}

@dynamic videoId, videoName, videoDescription, videoDate;

@end
