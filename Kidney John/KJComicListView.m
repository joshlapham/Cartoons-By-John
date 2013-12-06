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
    return UIEdgeInsetsMake(20, 20, 20, 20);
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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[KJComicCell class] forCellWithReuseIdentifier:@"comicCell"];
    
    // Add comic thumbs to local array
    self.comicImages = [NSMutableArray arrayWithObjects:@"aeroplane.png", @"arewethereyet.png", @"armymen.png", @"baby.png", @"bait.png", @"bath.png", @"beatbox.png", @"bird.png", @"blooddonor.png", @"boo.png", @"bride.png", @"cake.png", @"cave.png", @"celery.png", @"chimney.png", @"clothes.png", @"clouds.png", @"coffee.png", @"condom.png", @"confessional.png", @"corset.png", @"costume.png", @"customer.png", @"delivery.png", @"diarrhoea.png", @"director.png", @"dishes.png", @"dog.png", @"ear.png", @"earthquake.png", @"eggs.png", @"extinction.png", @"fathersday.png", @"feed.png", @"finger.png", @"flamingo.png", @"flies.png", @"frame.png", @"fries.png", @"genie.png", @"glasses.png", @"goingdown.png", @"goodtimes.png", @"graphics.png", @"guys.png", @"haircut.png", @"hangman.png", @"homeless.png", @"indian.png", @"inside.png", @"inspace.png", @"ispy.png", @"johnson.png", @"keyrings.png", @"kiss.png", @"knockknock.png", @"lightning.png", @"lumberjack.png", @"matress.png", @"microwave.png", @"mosquito.png", @"mothers.png", @"mousetrap.png", @"newyearsresolution.png", @"on.png", @"organised.png", @"paintings.png", @"phone.png", @"pick.png", @"pinata.png", @"poker.png", @"president.png", @"puppies.png", @"razor.png", @"redridinghood.png", @"refund.png", @"roadsigns.png", @"rooster.png", @"sandwich.png", @"santa.png", @"saveme.png", @"shark.png", @"smell.png", @"snowman.png", @"stpatricksday.png", @"surgeon.png", @"tampon.png", @"taste.png", @"text.png", @"topless.png", @"tupperware.png", @"tyrannosaurus.png", @"virus.png", @"water.png", @"weekend.png", @"windbreaker.png", @"wire.png", @"wolf.png", @"worm.png", @"zitpatrol.png", nil];
    
    // TESTING
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    //NSURL *bundleURL = [[NSBundle mainBundle] pathForResource:@"" ofType:@"png" inDirectory:@"Comics"];
    //NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                   //includingPropertiesForKeys:@[]
                                                      //options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        //error:nil];
    
    //NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] resourcePath] error:Nil];
    
    //for (NSString *path in contents) {
        //NSLog(@"FILE: %@", path);
    //}
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension ENDSWITH '.png'"];
//    for (NSString *path in [contents filteredArrayUsingPredicate:predicate]) {
//        // Enumerate each .png file in directory
//        NSLog(@"FILE: %@", path);
//    }
    
    //self.comicThumbImages = [NSMutableArray arrayWithObjects:, nil];
    
    self.title = @"Comix";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
