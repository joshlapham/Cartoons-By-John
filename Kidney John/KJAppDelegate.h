//
//  KJAppDelegate.h
//  Kidney John
//
//  Created by jl on 1/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) __block NSMutableArray *videosArrayToSendToDelegate;

@end
