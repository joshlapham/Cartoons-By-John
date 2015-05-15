//
//  KJSecretAdminViewController.m
//  Kidney John
//
//  Created by jl on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSecretAdminViewController.h"

// ENUMs
// Data type for view
typedef NS_ENUM(NSUInteger, KJSecretAdminDataType) {
    KJSecretAdminDataTypeVideos,
    KJSecretAdminDataTypeComics,
    KJSecretAdminDataTypeDoodles,
    KJSecretAdminDataTypeLinks,
    KJSecretAdminDataTypeMisc,
};

@interface KJSecretAdminViewController () <UIToolbarDelegate>

// Properties
@property (nonatomic) KJSecretAdminDataType dataTypeForView;

@end

@implementation KJSecretAdminViewController

#pragma mark - dealloc method

- (void)dealloc {
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prevent segmented control from being hidden
    self.navigationController.navigationBar.translucent = NO;
    
    // Init 'Done' navbar button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(didTapDoneButton:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    // Init 'Action' navbar button
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(didTapActionButton:)];
    self.navigationItem.rightBarButtonItem = actionButton;
}

#pragma mark - UIToolbarDelegate methods

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

#pragma mark - Action handler methods

- (IBAction)didTapDoneButton:(id)sender {
    // Go back to previous view (back to the app)
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)didTapActionButton:(id)sender {
    // Init action sheet
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Init actions
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *resetPasswordAction = [UIAlertAction actionWithTitle:@"Reset Password"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    // TODO: finish implementing this
                                                                }];
    
    [actionSheet addAction:resetPasswordAction];
    [actionSheet addAction:cancelAction];
    
    // Present action sheet
    // TODO: implement completion block to re-fetch data in app
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

#pragma mark - Getter/setter override methods

- (void)setDataTypeForView:(KJSecretAdminDataType)dataTypeForView {
    _dataTypeForView = dataTypeForView;
    
    // TODO: implement this method
    
    NSLog(@"%s", __func__);
}

@end
