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
@property (nonatomic, retain) NSString * videoCellHeight;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSData * videoThumb;
@property (nonatomic) BOOL isFavourite;

@end
