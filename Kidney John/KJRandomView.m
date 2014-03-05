//
//  KJRandomView.m
//  Kidney John
//
//  Created by jl on 3/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJRandomView.h"
#import "MBProgressHUD.h"
#import "Models/KJRandomImage.h"
#import "KJDoodleStore.h"
#import "KJDoodleCell.h"

@interface KJRandomView () <UIAlertViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KJRandomView {
    __block NSArray *randomImagesResults;
    NSString *currentRandomImageUrl;
}

#pragma mark - setup collection view method

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    
    // use up whole screen (or frame)
    [flowLayout setItemSize:self.collectionView.frame.size];
    
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView reloadData];
}

#pragma mark - collection view delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [randomImagesResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJDoodleCell *cell = (KJDoodleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"doodleCell" forIndexPath:indexPath];
    
    KJRandomImage *cellData = [randomImagesResults objectAtIndex:indexPath.row];
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        UIImage *thumbImage = [UIImage imageWithData:cellData.imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor whiteColor];
            cell.doodleImageView.image = thumbImage;
        });
    });
    
    return cell;

}

#pragma mark - NSNotification methods

- (void)doodleFetchDidHappen
{
    //NSLog(@"== doodle fetch did happen ==");
    
    // Hide progress
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Hide network activity monitor
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Load a random image
    [self loadRandomImages];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"RANDOM: did dismiss instructions alert view, setting user defaults accordingly");
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"doodleInstructionsShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Load Doodles method

- (void)loadRandomImages
{
    NSLog(@"RANDOM: in loadRandomImages method ...");
    randomImagesResults = [[NSArray alloc] init];
    randomImagesResults = [KJRandomImage MR_findAll];
    
    // Hide network activity monitor
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Display alert with instructions on how to use this screen on first load
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"doodleInstructionsShown"]) {
        NSLog(@"RANDOM: instructions have not yet been shown to user; now displaying");
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Doodles"
                                                     message:@"Swipe left to load a new random doodle."
                                                    delegate:self
                                           cancelButtonTitle:Nil
                                           otherButtonTitles:@"OK", nil];
        [av show];
    } else {
        NSLog(@"RANDOM: instructions HAVE been shown to user");
    }
    
    // setup collection view
    [self setupCollectionView];
}

#pragma mark - Return random image from an array

- (UIImage *)getRandomImageFromArray:(NSArray *)arrayToCheck
{
    NSString *stringToReturn = [[NSString alloc] init];
    UIImage *imageToReturn;
    
    // Get random URL if it wasn't just displayed
    do {
        // TODO: check if array is empty, error if so
        NSUInteger randomIndex = arc4random() % [arrayToCheck count];
        //stringToReturn = [NSString stringWithFormat:@"%@", [arrayToCheck objectAtIndex:randomIndex]];
        KJRandomImage *returnedRandomImage = [arrayToCheck objectAtIndex:randomIndex];
        stringToReturn = returnedRandomImage.imageUrl;
        imageToReturn = [UIImage imageWithData:returnedRandomImage.imageData];
    } while ([stringToReturn isEqualToString:currentRandomImageUrl]);
    
    // Set last URL variable to the URL string we're using
    currentRandomImageUrl = stringToReturn;
    
    return imageToReturn;
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Doodles";
    
    // Register custom UICollectionViewCell
    [self.collectionView registerClass:[KJDoodleCell class] forCellWithReuseIdentifier:@"doodleCell"];
    
    // Show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading doodles ...";
    
    // NSNotifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doodleFetchDidHappen) name:@"KJDoodleDataFetchDidHappen" object:nil];
    
    // Use the DoodleStore to fetch doodle data
    KJDoodleStore *store = [[KJDoodleStore alloc] init];
    [store fetchDoodleData];
}

@end
