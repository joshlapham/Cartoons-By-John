//
//  KJSecretAdminViewController.m
//  Kidney John
//
//  Created by jl on 16/05/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import "KJSecretAdminViewController.h"
#import "KJVideoDataSource.h"
#import "KJAdminStore.h"
#import "KJVideoCollectionViewCell.h"

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
@property (nonatomic, strong) id dataSourceForView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJSecretAdminViewController

#pragma mark - dealloc method

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KJAdminStoreVideoDataFetchDidHappenNotification
                                                  object:nil];
}

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    self.title = @"Admin";
    
    // Register for NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adminStoreVideoDataFetchDidHappen:)
                                                 name:KJAdminStoreVideoDataFetchDidHappenNotification
                                               object:nil];
    
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
    
    // Setup collectionView
    [self setupCollectionView];
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView {
    // Register cell
    //    [_collectionView registerClass:[KJVideoCollectionViewCell class]
    //        forCellWithReuseIdentifier:[KJVideoCollectionViewCell cellIdentifier]];
    [_collectionView registerNib:[UINib nibWithNibName:[KJVideoCollectionViewCell cellIdentifier]
                                                bundle:nil]
      forCellWithReuseIdentifier:[KJVideoCollectionViewCell cellIdentifier]];
    
    // Init flow layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.minimumInteritemSpacing = 0.1f;
    flowLayout.minimumLineSpacing = 1.0f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(300, 50);
    
    // Init collectionView
    _collectionView.collectionViewLayout = flowLayout;
    _collectionView.backgroundColor = [UIColor lightGrayColor];
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
    // TODO: update to use string constants
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

- (IBAction)segmentedControlIndexDidChange:(id)sender {
    NSLog(@"%@ - %s", [self class], __func__);
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    
    // TODO: implement this method
    [self setDataTypeForView:control.selectedSegmentIndex];
}

#pragma mark NSNotification handler methods

- (IBAction)adminStoreVideoDataFetchDidHappen:(id)sender {
    NSLog(@"%@ - %s", [self class], __func__);
    
    // TODO: reload data
    KJVideoDataSource *videoDataSource = (KJVideoDataSource *)_dataSourceForView;
    [videoDataSource setCellDataSource:[[KJAdminStore sharedStore] fetchedVideos]];
    self.collectionView.dataSource = videoDataSource;
    
    [self.collectionView reloadData];
}

#pragma mark - Getter/setter override methods

- (void)setDataTypeForView:(KJSecretAdminDataType)dataTypeForView {
    _dataTypeForView = dataTypeForView;
    
    // TODO: implement this method
    
    NSLog(@"%s", __func__);
    NSLog(@"%s - set data type for view to : %lu", __func__, (unsigned long)_dataTypeForView);
    
    if (_dataTypeForView == KJSecretAdminDataTypeVideos) {
        NSLog(@"%s - chose Videos", __func__);
        
        // Init data source
        _dataSourceForView = [[KJVideoDataSource alloc] init];
        
        // Fetch video data for view
        [[KJAdminStore sharedStore] fetchVideoData];
        
        // TODO: set cell array on data source
        // TODO: refresh view with data
    }
}

@end
