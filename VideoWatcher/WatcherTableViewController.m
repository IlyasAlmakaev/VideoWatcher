//
//  WatcherTableViewController.m
//  VideoWatcher
//
//  Created by almakaev iliyas on 18/05/15.
//  Copyright (c) 2015 almakaev iliyas. All rights reserved.
//

#import "WatcherTableViewController.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Video.h"


@interface WatcherTableViewController ()

@property Video *video;
@property (strong, nonatomic) AppDelegate *appD;

@end

@implementation WatcherTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appD = [[AppDelegate alloc] init];
    [self parse];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)parse
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.youtube.com/channel/UCtxxJi5P0rk6rff3_dCfQVw/videos"]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         TFHpple *parser = [[TFHpple alloc] initWithHTMLData:responseObject];
         
         NSString *pathQueryString = @"//div[@class='yt-lockup-content']";
         
         NSArray *nodes = [parser searchWithXPathQuery:pathQueryString];
         
         for (TFHppleElement *elements in nodes)
         {
             self.video = [NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                       inManagedObjectContext:self.appD.managedOC];
             
             TFHppleElement *element;
             NSString *name = [[[elements firstChildWithClassName:@"yt-lockup-title"] firstChildWithClassName:@"yt-uix-sessionlink yt-uix-tile-link  spf-link  yt-ui-ellipsis yt-ui-ellipsis-2"] objectForKey:@"title"];
             
             NSString *descript = [[elements firstChildWithClassName:@"yt-lockup-byline"] firstChildWithTagName:@"a"].text;
             
             NSString *time = [[elements firstChildWithClassName:@"yt-lockup-title"] firstChildWithTagName:@"span"].text;
             
             NSString *poster = [[[elements firstChildWithClassName:@"yt-lockup-title"] firstChildWithClassName:@"yt-uix-sessionlink yt-uix-tile-link  spf-link  yt-ui-ellipsis yt-ui-ellipsis-2"] objectForKey:@"href"];
             
        //      NSString *descript = [[[elements firstChildWithClassName:@"yt-lockup-byline"]firstChildWithClassName:@"g-hovercard yt-uix-sessionlink yt-user-name  spf-link "] objectForKey:@"aria-label"];
             
      /*       self.news.title = [[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"].text;
             
             self.news.date = [[element firstChildWithClassName:@"topic-header"] firstChildWithTagName:@"time"].text;
             
             self.news.image = [[[[elements firstChildWithClassName:@"preview"] firstChildWithTagName:@"a"] firstChildWithTagName:@"img"] objectForKey:@"src"];
             
             self.news.reference = [[[[element firstChildWithClassName:@"topic-header"] firstChildWithClassName:@"topic-title word-wrap"] firstChildWithTagName:@"a"] objectForKey:@"href"];
             
             [self.newsContent addObject:self.news];*/
             NSLog(@"%@", poster);
         }
         
    //     [self.tableView reloadData];
    //     [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.5];
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
    
    [operation start];
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
