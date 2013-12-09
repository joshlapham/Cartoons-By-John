//
//  KJRandomImageProtocol.h
//  Kidney John
//
//  Created by jl on 9/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

// Delegate definition
@protocol KJRandomImageProtocol <NSObject>
@optional

- (void)dayOfWeekChosen:(NSString *)withDay;
- (void)updateMap;

@end

@interface KJRandomImageProtocol : NSObject
{
    // Delegate to respond back
    id <KJRandomImageProtocol> _delegate;
}

@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) __block NSMutableArray *randomImagesArray;
- (void)updateRandomImagesArrayWithImageUrl:(NSString *)aUrl;

@end
