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
#import "KJVideoEditViewController.h"
#import <MBProgressHUD.h>
#import "UIColor+KJColours.h"

// ENUMs
// Data type for view
typedef NS_ENUM(NSUInteger, KJSecretAdminDataType) {
    KJSecretAdminDataTypeVideos,
    KJSecretAdminDataTypeComics,
    KJSecretAdminDataTypeDoodles,
    KJSecretAdminDataTypeLinks,
    KJSecretAdminDataTypeMisc,
};

@interface KJSecretAdminViewController () <UIToolbarDelegate, UICollectionViewDelegate>

// Properties
@property (nonatomic) KJSecretAdminDataType dataTypeForView;
@property (nonatomic, strong) id dataSourceForView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJSecretAdminViewController {
    // Private property for YouTube API key
    NSString *youTubeApiKey;
}

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
    
    // Set YouTube API key property
    [self readAPIKeysFromPlist];
    
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
    
    // Fetch data for view
    // NOTE - we always start on 'Videos' segment
    // TODO: review this; possibly start on last-selected segment via NSUserDefaults?
    [self setDataTypeForView:KJSecretAdminDataTypeVideos];
}

#pragma mark - Read API keys from plist method

// TODO: refactor for reusability
// Currently using this method on App Delegate

- (void)readAPIKeysFromPlist {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"Keys.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Keys"
                                                    ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    // TODO: update to fix compiler errors
    
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    
    if (!temp) {
        DDLogError(@"%s - error reading Parse keys.plist: %@, format: %d", __func__, errorDesc, format);
    }
    
    youTubeApiKey = [temp objectForKey:@"youTubeApiKey"];
    
    //    DDLogVerbose(@"Parse App ID: %@, Client Key: %@", parseAppId, parseClientKey);
}

#pragma mark - Setup collectionView method

- (void)setupCollectionView {
    // Register cell
    [_collectionView registerNib:[UINib nibWithNibName:[KJVideoCollectionViewCell cellIdentifier]
                                                bundle:nil]
      forCellWithReuseIdentifier:[KJVideoCollectionViewCell cellIdentifier]];
    
    // Init flow layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 2.0f;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 93);
    
    // Init collectionView
    _collectionView.collectionViewLayout = flowLayout;
    _collectionView.backgroundColor = [UIColor kj_viewBackgroundColour];
    _collectionView.delegate = self;
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
    
    UIAlertAction *addNewAction = [UIAlertAction actionWithTitle:@"Add New Video"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             // Show add new video alert
                                                             [self didTapAddNewVideo:nil];
                                                         }];
    
    [actionSheet addAction:addNewAction];
    [actionSheet addAction:resetPasswordAction];
    [actionSheet addAction:cancelAction];
    
    // Present action sheet
    // TODO: implement completion block to re-fetch data in app
    [self presentViewController:actionSheet
                       animated:YES
                     completion:nil];
}

- (IBAction)didTapAddNewVideo:(id)sender {
    // Init alert
    UIAlertController *addNewAlert = [UIAlertController alertControllerWithTitle:@"Add New Video"
                                                                         message:@"Type the YouTube video ID.\nThis is the unique identifier found in the video URL."
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    // Init text field
    [addNewAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"YouTube Video ID";
        textField.returnKeyType = UIReturnKeyDone;
        
        // TODO: remove this after debugging!
        textField.text = @"WfoK2KLKzWc";
    }];
    
    // Init actions
    UIAlertAction *fetchAction = [UIAlertAction actionWithTitle:@"Fetch"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            // TODO: fetch data from YouTube API
                                                            [self didEnterVideoIdToFetch:addNewAlert];
                                                        }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [addNewAlert addAction:fetchAction];
    [addNewAlert addAction:cancelAction];
    
    // Show alert
    [self presentViewController:addNewAlert
                       animated:YES
                     completion:nil];
}

- (IBAction)segmentedControlIndexDidChange:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    [self setDataTypeForView:control.selectedSegmentIndex];
}

- (IBAction)didEnterVideoIdToFetch:(id)sender {
    UIAlertController *fetchAlert = (UIAlertController *)sender;
    UITextField *fetchTextField = [fetchAlert.textFields firstObject];
    
    // GUARD - empty text field
    if (!fetchTextField.text.length) {
        // TODO: show alert again?
        return;
    }
    
    else {
        // Show progress
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [MBProgressHUD showHUDAddedTo:self.view
                             animated:YES];
        
        // Init video ID to fetch
        NSString *videoIdToFetch = fetchTextField.text;
        
        // Init API URL
        NSString *apiUrl = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?id=%@&part=snippet,contentDetails&key=%@", videoIdToFetch, youTubeApiKey];
        
        // Init request
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        [[session dataTaskWithURL:[NSURL URLWithString:apiUrl]
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    // Hide progress
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    [MBProgressHUD hideAllHUDsForView:self.view
                                             animated:YES];
                    
                    if (!error) {
                        // Parse JSON response
                        NSError *jsonError;
                        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:kNilOptions
                                                                                  error:&jsonError];
                        
                        // If all went well ..
                        if (!jsonError) {
                            // Init fetched properties
                            NSString *fetchedName = [[results valueForKeyPath:@"items.snippet.title"] firstObject];
                            NSString *fetchedDescription = [[results valueForKeyPath:@"items.snippet.description"] firstObject];
                            NSString *fetchedDate = [[results valueForKeyPath:@"items.snippet.publishedAt"] firstObject];
                            NSString *parsedDate = [[fetchedDate componentsSeparatedByString:@"T"] firstObject];
                            NSString *fetchedDuration = [[results valueForKeyPath:@"items.contentDetails.duration"] firstObject];
                            NSString *parsedDuration = [[fetchedDuration componentsSeparatedByString:@"PT"] lastObject];
                            
                            NSLog(@"%s - fetched video:\nNAME : %@\nDESC : %@\nDATE : %@\nDURATION : %@", __func__, fetchedName, fetchedDescription, parsedDate, parsedDuration);
                            
                            // Show alert with fetched details
                            // Init alert
                            NSString *alertMessage = [NSString stringWithFormat:@"Are these details correct?\n\nTitle: %@\nDescription: %@\nDate: %@\nDuration: %@", fetchedName, fetchedDescription, parsedDate, parsedDuration];
                            UIAlertController *fetchedDataAlert = [UIAlertController alertControllerWithTitle:@"Fetched Details"
                                                                                                      message:alertMessage
                                                                                               preferredStyle:UIAlertControllerStyleAlert];
                            
                            // Init actions
                            UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                                                style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction *action) {
                                                                                  // Init new PFObject
                                                                                  PFObject *newVideo = [PFObject objectWithClassName:@"Video"];
                                                                                  [newVideo setValue:fetchedName
                                                                                              forKey:@"videoName"];
                                                                                  [newVideo setValue:fetchedDescription
                                                                                              forKey:@"videoDescription"];
                                                                                  [newVideo setValue:parsedDate
                                                                                              forKey:@"date"];
                                                                                  [newVideo setValue:[NSNull null]
                                                                                              forKey:@"is_active"];
                                                                                  [newVideo setValue:videoIdToFetch
                                                                                              forKey:@"videoId"];
                                                                                  [newVideo setValue:parsedDuration
                                                                                              forKey:@"videoDuration"];
                                                                                  
                                                                                  // Init Edit Video VC
                                                                                  KJVideoEditViewController *viewController = [[KJVideoEditViewController alloc] initWithItemType:KJVideoEditItemTypeNew];
                                                                                  [viewController setChosenVideo:newVideo];
                                                                                  
                                                                                  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                                                                                  
                                                                                  // Present VC modally
                                                                                  [self presentViewController:navController
                                                                                                     animated:YES
                                                                                                   completion:nil];
                                                                                  
                                                                              }];
                            
                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                                   style:UIAlertActionStyleCancel
                                                                                 handler:nil];
                            
                            [fetchedDataAlert addAction:yesAction];
                            [fetchedDataAlert addAction:cancelAction];
                            
                            // Show alert
                            [self presentViewController:fetchedDataAlert
                                               animated:YES
                                             completion:nil];
                        }
                        
                        // Handle parse JSON error
                        else {
                            // TODO: implement
                            NSLog(@"%s - JSON PARSE ERROR : %@", __func__, [jsonError localizedDescription]);
                        }
                    }
                    
                    // Handle error
                    else {
                        // TODO: implement
                        NSLog(@"%s - FETCH ERROR : %@", __func__, [error localizedDescription]);
                    }
                }]
         
         // Start request
         resume];
    }
}

#pragma mark NSNotification handler methods

- (IBAction)adminStoreVideoDataFetchDidHappen:(id)sender {
    KJVideoDataSource *videoDataSource = (KJVideoDataSource *)_dataSourceForView;
    [videoDataSource setCellDataSource:[[KJAdminStore sharedStore] fetchedVideos]];
    self.collectionView.dataSource = videoDataSource;
    
    // Hide progress
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideAllHUDsForView:self.view
                             animated:YES];
    
    // Reload data
    [self.collectionView reloadData];
}

#pragma mark - Getter/setter override methods

- (void)setDataTypeForView:(KJSecretAdminDataType)dataTypeForView {
    _dataTypeForView = dataTypeForView;
    
    // Show progress
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    // Videos
    if (_dataTypeForView == KJSecretAdminDataTypeVideos) {
        NSLog(@"%s - chose Videos", __func__);
        
        // Init data source
        _dataSourceForView = [[KJVideoDataSource alloc] init];
        
        // Fetch video data for view
        [[KJAdminStore sharedStore] fetchVideoData];
    }
    
    // TODO: finish this method
    else {
        // Hide progress
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];
        
        //        [_collectionView performBatchUpdates:^{
        ////            _collectionView deleteItemsAtIndexPaths:[_collectionView index]
        //            _collectionView.dataSource = nil;
        ////            _collectionView.delegate = nil;
        //
        ////            _dataSourceForView = nil;
        //        } completion:^(BOOL finished) {
        //            // Reload data
        ////            [_collectionView reloadData];
        //        }];
    }
}

#pragma mark - UICollectionViewDelegate methods

-   (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataTypeForView == KJSecretAdminDataTypeVideos) {
        KJVideoEditViewController *viewController = [[KJVideoEditViewController alloc] initWithItemType:KJVideoEditItemTypeExisting];
        KJVideoDataSource *dataSource = (KJVideoDataSource *)_dataSourceForView;
        PFObject *cellData = (PFObject *)[dataSource.cellDataSource objectAtIndex:indexPath.row];
        viewController.chosenVideo = cellData;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewController:navController
                           animated:YES
                         completion:nil];
    }
}

@end
