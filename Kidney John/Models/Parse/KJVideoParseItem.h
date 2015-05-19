//
//  KJVideoParseItem.h
//  Kidney John
//
//  Created by Josh Lapham on 19/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Parse/Parse.h>

@interface KJVideoParseItem : PFObject

// Properties
@property (nonatomic, strong) NSString * videoId;
@property (nonatomic, strong) NSString * videoName;
@property (nonatomic, strong) NSString * videoDescription;
@property (nonatomic, strong) NSString * date;
// TODO: BOOL on Parse is string?
//@property (nonatomic) BOOL isActive;
@property (nonatomic, strong) NSString * videoDuration;

// Parse helper methods
+ (NSString *)parseClassName;

@end
