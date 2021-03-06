//
//  KJVideo.h
//  Kidney John
//
//  Created by jl on 18/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KJVideo : NSManagedObject

@property (nonatomic, retain) NSString * videoId;
@property (nonatomic, retain) NSString * videoName;
@property (nonatomic, retain) NSString * videoDescription;
@property (nonatomic, retain) NSString * videoDate;
@property (nonatomic) BOOL isFavourite;
@property (nonatomic) BOOL isActive;
@property (nonatomic, retain) NSString * videoDuration;

@end
