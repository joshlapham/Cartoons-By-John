//
//  KJSocialLink.h
//  Kidney John
//
//  Created by jl on 15/11/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KJSocialLink : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * imageUrl;

@end
