//
//  KJRandomImageFromParse.h
//  Kidney John
//
//  Created by jl on 9/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@interface KJRandomImageFromParse : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *imageId;
@property (retain) NSString *imageUrl;
@property (retain) NSString *imageDescription;
@property (retain) NSDate *imageDate;

@end
