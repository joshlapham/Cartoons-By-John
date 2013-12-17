//
//  KJRandomImageFromParse.m
//  Kidney John
//
//  Created by jl on 9/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomImageFromParse.h"
#import "PFObject+Subclass.h"

@implementation KJRandomImageFromParse

@dynamic imageId, imageUrl, imageDescription, imageDate;

+ (NSString *)parseClassName
{
    return @"RandomImage";
}

@end
