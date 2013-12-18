//
//  KJComicFromParse.h
//  Kidney John
//
//  Created by jl on 18/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@interface KJComicFromParse : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *comicName;
@property (retain) NSData *comicData;
@property (retain) NSData *comicThumbData;

@end
