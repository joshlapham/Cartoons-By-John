//
//  KJRandomView.h
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJRandomView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *randomImage;

@property (nonatomic, strong) __block NSMutableArray *randomImageArray;
@property (nonatomic, strong) __block NSMutableArray *imageIdResults;
@property (nonatomic, strong) __block NSMutableArray *imageUrlResults;
@property (nonatomic, strong) __block NSMutableArray *imageDescriptionResults;
@property (nonatomic, strong) __block NSMutableArray *imageDateResults;

- (UIImage *)getRandomImageFromArray;

@end
