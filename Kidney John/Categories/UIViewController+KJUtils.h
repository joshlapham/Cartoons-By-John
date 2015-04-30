//
//  UIViewController+KJUtils.h
//  Kidney John
//
//  Created by Josh Lapham on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (KJUtils)

// Methods
// All view controllers
// Fatal error alert
- (void)showFatalErrorAlert;

// Video view controllers
- (void)kj_showErrorIfNoNetworkConnectionForVideoDetailView;

// Favourites view controllers
- (void)kj_showthereAreNoFavouritesAlertWithTitle:(NSString *)viewTitle;

@end
