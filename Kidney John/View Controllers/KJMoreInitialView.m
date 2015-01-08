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
#import "KJSocialLinkStore.h"
#import "KJFavDoodlesListView.h"
#import "JPLReachabilityManager.h"
#import <Reachability/Reachability.h>
#import "KJSocialLink.h"
#import "UIFont+KJFonts.h"
#import "UIColor+KJColours.h"

@interface KJMoreInitialView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation KJMoreInitialView {
    NSArray *cellArray;
    NSInteger chosenRow;
    NSMutableArray *socialLinksArray;
    BOOL areWeTestingSocialLinksFromParseFeature;
}

#pragma mark - UITableView delegate methods

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
            return NSLocalizedString(@"Favourites", @"Header title for Favourites buttons in More view");
            break;
            
        case 1:
            return NSLocalizedString(@"Like, Comment, Subscribe", @"Header title for social media buttons in More view");
            break;
            
        default:
            // TODO: review this
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
    headerLabel.font = [UIFont kj_sectionHeaderFont];
    headerLabel.textColor = [UIColor kj_moreViewSectionTextColour];
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
    
    // Set font
    titleLabel.font = [UIFont kj_moreViewCellFont];
    
    // If Favourites section ..
    if (indexPath.section == 0) {
        // Set the cell text
        titleLabel.text = [cellArray objectAtIndex:indexPath.row];
        
        // Set Favourites icon
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
        
        // FOR TESTING
        if (areWeTestingSocialLinksFromParseFeature == YES) {
            // From Parse
            KJSocialLink *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
            titleLabel.text = socialLink.title;
            thumbImage.image = [UIImage imageNamed:socialLink.imagePath];
        } else {
            // Use hardcoded social links
            NSDictionary *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
            titleLabel.text = [socialLink objectForKey:@"title"];
            thumbImage.image = [UIImage imageNamed:[socialLink objectForKey:@"image"]];
        }
        
        // Give the social icons a bit of opacity to match Favourites icons
        thumbImage.alpha = 0.5;
        
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
                
                // FOR TESTING
                if (areWeTestingSocialLinksFromParseFeature == YES) {
                    // Use Parse
                    KJSocialLink *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
                    webViewController.URL = [NSURL URLWithString:socialLink.url];
                    webViewController.title = socialLink.title;
                } else {
                    // Use hardcoded social links
                    NSDictionary *socialLink = [socialLinksArray objectAtIndex:indexPath.row];
                    webViewController.URL = [NSURL URLWithString:[socialLink objectForKey:@"url"]];
                    webViewController.title = [socialLink objectForKey:@"title"];
                }
                
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

#pragma mark - Prepare for segue method

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
        // If Doodles ..
        // NOTE: don't need to set anything here
        //KJFavDoodlesListView *destViewController = segue.destinationViewController;
    }
}

#pragma mark - Reachability methods

- (void)reachabilityDidChange
{
    if ([JPLReachabilityManager isReachable]) {
        DDLogVerbose(@"More: network became available");
        
        // Fetch data
        [KJSocialLinkStore fetchSocialLinkData];
    }
}

#pragma mark - Did fetch Social Links method

- (void)didFetchSocialLinks
{
    DDLogVerbose(@"More: did fetch social links");
    
    // Clear out existing links
    [socialLinksArray removeAllObjects];
    
    // Get links from Core Data
    socialLinksArray = [NSMutableArray arrayWithArray:[KJSocialLink MR_findAll]];
    
    // Reload tableView
    [self.tableView reloadData];
}

#pragma mark - Init cell array methods

// NOTE - since we are still testing fetching of Social Links from Parse,
// these methods are here for that purpose

- (void)initSocialLinksArrayFromParse
{
    // Init social link data source array
    socialLinksArray = [NSMutableArray arrayWithArray:[KJSocialLink MR_findAll]];
    
    // Reload tableView
    [self.tableView reloadData];
    
    // Check if network is reachable
    if ([JPLReachabilityManager isReachable]) {
        // Fetch social links from Parse
        [KJSocialLinkStore fetchSocialLinkData];
    }
}

- (void)initHardcodedSocialLinksArray
{
    NSDictionary *facebookLink = @{@"title" : @"Facebook", @"url" : @"https://www.facebook.com/kidneyjohn", @"image" : @"facebook.png"};
    NSDictionary *twitterLink = @{@"title" : @"Twitter", @"url" : @"https://twitter.com/johnrodpaine", @"image" : @"twitter.png"};
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
    
    self.title = NSLocalizedString(@"More", @"Title of More view");
    
    // FOR TESTING of fetching Social Link data from Parse
    areWeTestingSocialLinksFromParseFeature = NO;
    
    if (areWeTestingSocialLinksFromParseFeature == YES) {
        // Set up NSNotification receiving for when videoStore finishes data fetch
        NSString *notificationName = @"KJSocialLinkDataFetchDidHappen";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFetchSocialLinks)
                                                     name:notificationName
                                                   object:nil];
        
        // Reachability NSNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityDidChange)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // Init cell array
        [self initSocialLinksArrayFromParse];
    } else {
        // Use hardcoded links
        [self initHardcodedSocialLinksArray];
    }
    
    
    // Array of titles for Favourites cells
    // NOTE: these strings will be used as titles for their respective views when tapped
    NSString *videosString = NSLocalizedString(@"Videos", @"Title of Videos button for Favourites list");
    NSString *comicString = NSLocalizedString(@"Comix", @"Title of Comics button for Favourites list");
    NSString *doodlesString = NSLocalizedString(@"Doodles", @"Title of Doodles button for Favourites list");
    cellArray = [NSArray arrayWithObjects:videosString, comicString, doodlesString, nil];
}

- (void)dealloc
{
    // Remove NSNotification observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KJSocialLinkDataFetchDidHappen" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
