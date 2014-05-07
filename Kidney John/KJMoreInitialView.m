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
    NSArray *socialCellArray;
    NSInteger chosenRow;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            {
                return [cellArray count];
            }
            break;
        
        case 1:
            {
                return [socialCellArray count];
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
            //NSLog(@"section 0");
            return [NSString stringWithFormat:@"Favourites"];
            break;
            
        case 1:
            //NSLog(@"section 1");
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
    //cell.textLabel.font = kjCustomFont;
    titleLabel.font = kjCustomFont;
    
    // If Favourites section ..
    if (indexPath.section == 0) {
        // Set the cell text
        //cell.textLabel.text = [cellArray objectAtIndex:indexPath.row];
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
        titleLabel.text = [socialCellArray objectAtIndex:indexPath.row];
        
        // Give the social icons a bit of opacity to match Favourites icons
        thumbImage.alpha = 0.5;
        
        // TODO: set Social Media icon here
        switch (indexPath.row) {
            case 0:
                // Facebook
                thumbImage.image = [UIImage imageNamed:@"facebook.png"];
                break;
                
            case 1:
                // Twitter
                thumbImage.image = [UIImage imageNamed:@"twitter.png"];
                break;
                
            case 2:
                // Tumblr
                thumbImage.image = [UIImage imageNamed:@"tumblr.png"];
                break;
                
            case 3:
                // Youtube
                thumbImage.image = [UIImage imageNamed:@"youtube.png"];
                break;
                
            case 4:
                // Vimeo
                thumbImage.image = [UIImage imageNamed:@"vimeo.png"];
                break;
                
            case 5:
                // Instagram
                thumbImage.image = [UIImage imageNamed:@"instagram.png"];
                break;
                
            case 6:
                // Society6
                thumbImage.image = [UIImage imageNamed:@"society6.png"];
                break;
                
            default:
                break;
        }
        
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
                //[self performSegueWithIdentifier:@"socialSegue" sender:self];
                
                // Set back button to have no text
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                
                // Initialize the web view controller and set it's URL
                PBWebViewController *webViewController = [[PBWebViewController alloc] init];
                webViewController.URL = [self returnUrlForItemAtPath:indexPath];
                
                // These are custom UIActivity subclasses that will show up in the UIActivityViewController
                // when the action button is clicked
                //PBSafariActivity *activity = [[PBSafariActivity alloc] init];
                //webViewController.applicationActivities = @[activity];
                
                // This property also corresponds to the same one on UIActivityViewController
                // Both properties do not need to be set unless you want custom actions
                //webViewController.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToWeibo];
                
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
        //NSLog(@"in segue method ..");
        NSString *typeOfFavourite = [cellArray objectAtIndex:chosenRow];
        //NSLog(@"type of fav: %@", typeOfFavourite);
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

#pragma mark - Init methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.title = @"More";
    
    cellArray = [NSArray arrayWithObjects:@"Videos", @"Comix", @"Doodles", nil];
    socialCellArray = [NSArray arrayWithObjects:@"Facebook", @"Twitter", @"Tumblr", @"YouTube", @"Vimeo", @"Instagram", @"Society6", nil];

}

#pragma mark - Social media URL method

- (NSURL *)returnUrlForItemAtPath:(NSIndexPath *)indexPath
{
    // Check to see what link was clicked
    // REVIEW: cause this code kinda sucks
    switch (indexPath.row) {
        case 0:
            return [NSURL URLWithString:@"https://www.facebook.com/kidneyjohn"];
            break;
            
        case 1:
            return [NSURL URLWithString:@"https://twitter.com/kidneyjohn"];
            break;
            
        case 2:
            return [NSURL URLWithString:@"http://johnroderickpaine.tumblr.com"];
            break;
            
        case 3:
            return [NSURL URLWithString:@"https://www.youtube.com/user/kidneyjohn"];
            break;
            
        case 4:
            return [NSURL URLWithString:@"http://vimeo.com/johnroderickpaine"];
            break;
            
        case 5:
            return [NSURL URLWithString:@"http://instagram.com/johnroderickpaine"];
            break;
            
        case 6:
            return [NSURL URLWithString:@"http://society6.com/kidneyjohn"];
            
        default:
            NSLog(@"Error: no URL");
            return nil;
            break;
    }
}

@end
