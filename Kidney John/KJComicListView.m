//
//  KJComicListView.m
//  Kidney John
//
//  Created by jl on 2/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJComicListView.h"
#import "KJComicCell.h"
#import "KJComicDetailView.h"

@interface KJComicListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *comicImages;
@property (nonatomic, strong) NSArray *comicThumbImages;

@end

@implementation KJComicListView

#pragma mark UICollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"COMIC LIST: selected item - %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"comicDetailSegue" sender:self];
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.comicThumbImages count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *thumbnailsPath = [resourcePath stringByAppendingPathComponent:@"ComicThumbs"];
        NSString *thumbImageString = [self.comicThumbImages objectAtIndex:indexPath.row];
        NSString *thumbImagePath = [thumbnailsPath stringByAppendingPathComponent:thumbImageString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor = [UIColor whiteColor];
            [cell setThumbImage:thumbImagePath];
        });
    });
    
    return cell;
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        KJComicDetailView *destViewController = segue.destinationViewController;
        destViewController.nameFromList = [self.comicThumbImages objectAtIndex:selectedIndexPath.row];
        
        // Hide tabbar on detail view
        destViewController.hidesBottomBarWhenPushed = YES;
    }
}

#pragma mark init methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];
    
    // TESTING
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *thumbnailsPath = [resourcePath stringByAppendingPathComponent:@"ComicThumbs"];
    //NSString *comicsPath = [resourcePath stringByAppendingPathComponent:@"Comics"];
    NSError *error;
    self.comicThumbImages = [[NSArray alloc] init];
    self.comicThumbImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thumbnailsPath error:&error];
    NSLog(@"COMIC LIST: thumbnail img array count - %lu", (unsigned long)[self.comicThumbImages count]);
    // END OF TESTING
    
    self.title = @"Comix";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.comicThumbImages = nil;
}

@end
