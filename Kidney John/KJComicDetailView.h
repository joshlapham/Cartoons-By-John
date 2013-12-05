//
//  KJComicDetailView.h
//  Kidney John
//
//  Created by jl on 4/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KJComicDetailView : UIViewController

@property (nonatomic, weak) NSString *nameFromList;
@property (weak, nonatomic) IBOutlet UIImageView *comicImage;

@end
