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

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"comicDetailSegue"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        //NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        KJComicDetailView *destViewController = segue.destinationViewController;
        destViewController.nameFromList = [self.comicImages objectAtIndex:selectedIndexPath.row];
        //destViewController.nameFromList = @"baby.png";
    }
}

#pragma mark UICollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: select item
    NSLog(@"Selected item: %ld", (long)indexPath.row);
    [self performSegueWithIdentifier:@"comicDetailSegue" sender:self];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: deselect item
}

#pragma mark UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 50, 20);
}

#pragma mark UICollectionView datasource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.comicImages count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    KJComicCell *cell = (KJComicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"comicCell" forIndexPath:indexPath];
    
    //cell.backgroundColor = [UIColor darkGrayColor];
    cell.backgroundColor = [UIColor whiteColor];
    
    //[cell setNumber:indexPath.row];
    
    //UIImage *cellImage = [UIImage imageNamed:@"baby.png"];
    //cell.comicImage = cellImage;
    
    [cell setThumbImage:[self.comicImages objectAtIndex:indexPath.row]];
    
    
    return cell;
}

#pragma mark init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];
    
    // Add comic thumbs to local array
    self.comicImages = [NSMutableArray arrayWithObjects:@"aeroplane.png", @"arewethereyet.png", @"armymen.png", @"baby.png", @"bait.png", @"bath.png", @"beatbox.png", @"bird.png", @"blooddonor.png", @"boo.png", nil];
    
    // TESTING
    
    //self.comicThumbImages = [NSMutableArray arrayWithObjects:, nil];
    
    self.title = @"Comix";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
