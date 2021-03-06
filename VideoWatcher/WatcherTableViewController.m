//
//  WatcherTableViewController.m
//  VideoWatcher
//
//  Created by almakaev iliyas on 18/05/15.
//  Copyright (c) 2015 almakaev iliyas. All rights reserved.
//

#import "WatcherTableViewController.h"
#import "Video.h"
#import "WatcherTableViewCell.h"
#import "VideoTableViewCell.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "XCDYouTubeKit.h"
#import "AppDelegate.h"


@interface WatcherTableViewController () <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate>

@property Video *video;
@property (strong, nonatomic) AppDelegate *appD;
@property (strong, nonatomic) NSMutableArray *contentVideo;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSNumberFormatter *decimalFormatter;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;
@property (strong, nonatomic) UIView *customView;
@property (nonatomic) CGRect *fixedFrame;
@property (strong, nonatomic) UISwipeGestureRecognizer *recognizerView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property float heightOriginal;

@property (strong, nonatomic) NSDictionary *posts;
@property (strong, nonatomic) NSMutableArray *post;

@end

@implementation WatcherTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.contentVideo = [[NSMutableArray alloc] init];
        self.filteredList = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Видео";
       
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(rightSwipe:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    

    
    // No search results controller to display the search results in the current view
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"Поиск из популярного видео";
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WatcherTableViewCell" bundle:nil] forCellReuseIdentifier:@"id"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"idV"];
    
    self.appD = [[AppDelegate alloc] init];
    [self parse];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.video = [NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                               inManagedObjectContext:self.appD.managedOC];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.searchController.active)
    {
        return self.filteredList.count;
    }
    else
    {
        return self.contentVideo.count;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active)
    {
        self.video = [self.filteredList objectAtIndex:indexPath.row];
  //      self.video.select = [NSNumber numberWithBool:NO];
    }
    else
    {
        self.video = [self.contentVideo objectAtIndex:indexPath.row];
    }
    
    if ([self.video.select boolValue] == NO)
    {
        WatcherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
        
        [cell.nameCell setText:self.video.name];
        [cell.descriptCell setText:self.video.descript];
        [cell.timeCell setText:self.video.time];
        //    cell.timeCell.text = [self.news.date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [cell.imageCell setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http:%@",self.video.poster]]];
        //   NSLog(@"%@", self.video.poster);
        // Configure the cell...
        tableView.rowHeight = 147;
        
        return cell;
    }
    else
    {
        VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idV"];
        
        self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.video.reference];
        [self.videoPlayerViewController presentInView:cell.videoView];
        [self.videoPlayerViewController.moviePlayer play];
        
        [cell.name setText:self.video.name];
        [cell.descript setText:self.video.descript];
        self.video.select = [NSNumber numberWithBool:NO];
        
        tableView.rowHeight = 324;
        return cell;
    }
    
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active)
    {
        self.video = [self.filteredList objectAtIndex:indexPath.row];
    }
    else
    {
        self.video = [self.contentVideo objectAtIndex:indexPath.row];
    }
    
    self.video.select = [NSNumber numberWithBool:YES];
    [tableView reloadData];
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.video.select boolValue] == NO)
    return 147;
    else
    return 324;
}*/

- (void)parse
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.youtube.com/channel/UCtxxJi5P0rk6rff3_dCfQVw/videos"]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
         
         NSString *pathQueryString = @"//div[@class='yt-lockup-dismissable']";
         
         NSArray *nodes = [parser searchWithXPathQuery:pathQueryString];
         
         for (TFHppleElement *elements in nodes)
         {
             self.video = [NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                       inManagedObjectContext:self.appD.managedOC];
             
             self.video.name = [[[[elements firstChildWithClassName:@"yt-lockup-content"]firstChildWithClassName:@"yt-lockup-title"] firstChildWithClassName:@"yt-uix-sessionlink yt-uix-tile-link  spf-link  yt-ui-ellipsis yt-ui-ellipsis-2"] objectForKey:@"title"];
             self.video.descript = [[[elements firstChildWithClassName:@"yt-lockup-content"] firstChildWithClassName:@"yt-lockup-byline"] firstChildWithTagName:@"a"].text;
             self.video.time = [[[[elements firstChildWithClassName:@"yt-lockup-thumbnail"] firstChildWithTagName:@"span"] firstChildWithTagName:@"span"] firstChildWithTagName:@"span"].text;
             self.video.poster = [[[[[[[[elements firstChildWithClassName:@"yt-lockup-thumbnail"] firstChildWithTagName:@"span"] firstChildWithTagName:@"a"] firstChildWithTagName:@"span"] firstChildWithTagName:@"span"] firstChildWithTagName:@"span"] firstChildWithTagName:@"img"] objectForKey:@"src"];
             self.video.reference = [[[[elements firstChildWithClassName:@"yt-lockup-thumbnail"]  firstChildWithTagName:@"span"]firstChildWithClassName:@"yt-uix-button yt-uix-button-size-small yt-uix-button-default yt-uix-button-empty yt-uix-button-has-icon no-icon-markup addto-button video-actions spf-nolink hide-until-delayloaded addto-watch-later-button-sign-in yt-uix-tooltip"] objectForKey:@"data-video-ids"];
             self.video.select = [NSNumber numberWithBool:NO];
             NSLog(@"%@", self.video.reference);
             [self.contentVideo addObject:self.video];
         }
         [self.tableView reloadData];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
    
    [operation start];
    
  /*  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://www.googleapis.com/youtube/v3/videos" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];*/
}

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark -
#pragma mark === UISearchResultsUpdating ===
#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText
{
    NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
    NSString *searchAttribute = @"name";
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
    self.filteredList = [self.contentVideo filteredArrayUsingPredicate:resultPredicate];
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //do you right swipe stuff here. Something usually using theindexPath that you get that way
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    self.indexPath = [self.tableView indexPathForRowAtPoint:location];
    if (self.searchController.active)
    {
        self.video = [self.filteredList objectAtIndex:self.indexPath.row];
    }
    else
    {
        self.video = [self.contentVideo objectAtIndex:self.indexPath.row];
    }
    
    
    [self.customView removeFromSuperview];
    
    CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:self.indexPath];
    CGRect rectOfCellInSuperview = [self.tableView convertRect:rectOfCellInTableView toView:[self.tableView superview]];
    
    float height;
    float heightOriginal;
    if (self.customView.frame.origin.y == 0)
    {
        height = [[UIScreen mainScreen] bounds].size.height-230;
    }
    else
    {
        height = self.customView.frame.origin.y;
    }
    

    heightOriginal = rectOfCellInSuperview.origin.y + self.heightOriginal;
    
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(rectOfCellInSuperview.origin.x, heightOriginal, 320, 243)];
    CGRect newRect = CGRectMake([[UIScreen mainScreen] bounds].size.width - 210 , height, 200, 150);
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.customView.frame = newRect;
                     }];
                         
    
    [self.videoPlayerViewController presentInView:self.customView];
  
    
    [self.tableView addSubview:self.customView];
    
    [self LoadLeftSwipe];
    self.video.select = [NSNumber numberWithBool:NO];
    [self.tableView reloadData];
    
}

- (void)LoadLeftSwipe
{
    self.recognizerView = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(leftSwipe:)];
    
    
    [self.recognizerView setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.customView addGestureRecognizer:self.recognizerView];
    self.recognizerView.delegate = self;
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.customView.frame = CGRectOffset(self.customView.frame, - [[UIScreen mainScreen] bounds].size.width, 0);
                         [self.videoPlayerViewController.moviePlayer stop];
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect fixedFrame = self.customView.frame;
    fixedFrame.origin.y = [[UIScreen mainScreen] bounds].size.height-166 + scrollView.contentOffset.y;
    self.customView.frame = fixedFrame;
    self.heightOriginal = scrollView.contentOffset.y;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
