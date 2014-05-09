//
//  KJMoreInitialView.m
//  Kidney John
//
//  Created by jl on 13/12/13.
//  Copyright (c) 2013 Josh Lapham. All rights reserved.
//

#import "KJMoreInitialView.h"
#import "KJFavouritesListView.h"
#import "PBWebViewController.h"
#import "KJVideoStore.h"
#import "KJComicStore.h"
#import "KJDoodleStore.h"
#import "KJFavDoodlesListView.h"

@interface KJMoreInitialView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation KJMoreInitialView {
    NSArray *cellArray;
    NSInteger chosenRow;
    NSMutableArray *socialLinksArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            {
                return [cellArray count];
            }
            break;
        
        case 1:
            {
                return [socialLinksArray count];
            }
            break;
            
        default:
            break;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"Favourites"];
            break;
            
        case 1:
            return [NSString stringWithFormat:@"Like, Comment, Subscribe"];
            break;
            
        default:
            return [NSString stringWithFormat:@"LOL error"];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] init];
    
    headerLabel.frame = CGRectMake(20, 8, 320, 20);
    headerLabel.font = [UIFont fontWithName:@"JohnRoderickPaine" size:17];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SocialCellIdentifier = @"SocialLinkCell";
    
    UITableViewCell *cell;
    
    if (!cell) {
        if (indexPath.section == 1) {
            // Social links section
            [tableView registerNib:[UINib nibWithNibName:@"KJSocialLinkCell" bundle:nil] forCellReuseIdentifier:SocialCellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:SocialCellIdentifier forIndexPath:indexPath];
        } else {
            // Other sections (like Favourites)
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        }
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UIImageView *thumbImage = (UIImageView *)[cell viewWithTag:102];
    
    // Set custom font
    UIFont *kjCustomFont = [UIFont fontWithName:@"JohnRoderickPaine" size:20];
    titleLabel.font = kjCustomFont;
    
    // If Favourites section ..
    if (indexPath.section == 0) {
        // Set the cell text
        titleLabel.text = [cellArray objectAtIndex:indexPath.row];
        
        // set Favourites icon
        if (indexPath.row == 0) {
            // Videos
            thumbImage.image = [UIImage imageNamed:@"video-tab-icon.png"];
            // Fix the look of the Video thumbnail when in tableView
            thumbImage.contentMode = UIViewContentModeScaleAspectFit;
        } else if (indexPath.row == 1) {
            // Comix
            thumbImage.image = [UIImage imageNamed:@"comic-tab-icon.png"];
        } else if (indexPath.row == 2) {
            // Doodles
            thumbImage.image = [UIImage imageNamed:@"doodle-tab-icon.png"];
        }
        
    // If Social Links section ..
    } else {
        // Set the cell text
        NSDictionary *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
        titleLabel.text = [socialLink objectForKey:@"title"];
        
        // Give the social icons a bit of opacity to match Favourites icons
        thumbImage.alpha = 0.5;
        
        // Set social icon
        thumbImage.image = [UIImage imageNamed:[socialLink objectForKey:@"image"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            {
                chosenRow = indexPath.row;
                
                // If Doodles was tapped ..
                if (chosenRow == 2) {
                    // Doodles was chosen
                    [self performSegueWithIdentifier:@"doodleFavouriteSegue" sender:self];
                } else {
                    // Videos or Comix was chosen
                    [self performSegueWithIdentifier:@"favouritesSegue" sender:self];
                }
            }
            break;
            
        case 1:
            {
                // Social media links
                // Set back button to have no text
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                
                // Initialize the web view controller and set it's URL
                PBWebViewController *webViewController = [[PBWebViewController alloc] init];
                
                NSDictionary *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
                webViewController.URL = [NSURL URLWithString:[socialLink objectForKey:@"url"]];
                webViewController.title = [socialLink objectForKey:@"title"];
                
                // Hide tabbar on detail view
                webViewController.hidesBottomBarWhenPushed = YES;
                
                // Push it
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if ([[segue identifier] isEqualToString:@"favouritesSegue"]) {
        //DDLogVerbose(@"in segue method ..");
        NSString *typeOfFavourite = [cellArray objectAtIndex:chosenRow];
        //DDLogVerbose(@"type of fav: %@", typeOfFavourite);
        NSArray *favouritesDataToPass;
        
        KJFavouritesListView *destViewController = segue.destinationViewController;
        destViewController.titleForView = typeOfFavourite;
        
        if (chosenRow == 0) {
            // Videos
            favouritesDataToPass = [KJVideoStore returnFavouritesArray];
        } else if (chosenRow == 1) {
            // Comix
            favouritesDataToPass = [KJComicStore returnFavouritesArray];
        }
        
        destViewController.cellResults = favouritesDataToPass;
        
    } else if ([segue.identifier isEqualToString:@"doodleFavouriteSegue"]) {
        // If Doodles
        KJFavDoodlesListView *destViewController = segue.destinationViewController;
        [destViewController setTitle:@"Doodles"];
    }
}

#pragma mark - Init social links array

- (void)initSocialLinksArray
{
    NSDictionary *facebookLink = @{@"title" : @"Facebook", @"url" : @"https://www.facebook.com/kidneyjohn", @"image" : @"facebook.png"};
    NSDictionary *twitterLink = @{@"title" : @"Twitter", @"url" : @"https://twitter.com/kidneyjohn", @"image" : @"twitter.png"};
    NSDictionary *tumblrLink = @{@"title" : @"Tumblr", @"url" : @"http://johnroderickpaine.tumblr.com", @"image" : @"tumblr.png"};
    NSDictionary *youtubeLink = @{@"title" : @"YouTube", @"url" : @"https://www.youtube.com/user/kidneyjohn", @"image" : @"youtube.png"};
    NSDictionary *vimeoLink = @{@"title" : @"Vimeo", @"url" : @"http://vimeo.com/johnroderickpaine", @"image" : @"vimeo.png"};
    NSDictionary *instaLink = @{@"title" : @"Instagram", @"url" : @"http://instagram.com/johnroderickpaine", @"image" : @"instagram.png"};
    NSDictionary *societyLink = @{@"title" : @"Society6", @"url" : @"http://society6.com/kidneyjohn", @"image" : @"society6.png"};
    
    socialLinksArray = [[NSMutableArray alloc] init];
    [socialLinksArray addObject:facebookLink];
    [socialLinksArray addObject:twitterLink];
    [socialLinksArray addObject:tumblrLink];
    [socialLinksArray addObject:youtubeLink];
    [socialLinksArray addObject:vimeoLink];
    [socialLinksArray addObject:instaLink];
    [socialLinksArray addObject:societyLink];
}

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"More";
    
    cellArray = [NSArray arrayWithObjects:@"Videos", @"Comix", @"Doodles", nil];
    
    // Init social links array
    [self initSocialLinksArray];
}

@end
