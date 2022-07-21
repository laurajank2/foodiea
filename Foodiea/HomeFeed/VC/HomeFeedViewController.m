//
//  HomeFeedViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "HomeFeedViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "HomeCell.h"
#import "DetailMapViewController.h"
#import "ProfileViewController.h"
#import "FilterViewController.h"

@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource, FilterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *homeFeedTableView;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *profileBtn;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSArray *allPosts;
@property NSString *price;
@property double userLat;
@property double userLong;
@property double distance;
@property APIManager *manager;
@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.homeFeedTableView.delegate = self;
    self.homeFeedTableView.dataSource = self;
    self.manager = [[APIManager alloc] init];
    [self paginationSetUp];
    [self chooseFetch];
    
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(chooseFetch) forControlEvents:UIControlEventValueChanged];
    [self.homeFeedTableView insertSubview:self.refreshControl atIndex:0];
    [self setNavBtns];

}

-(void) paginationSetUp {
    self.noMoreResultsAvail = NO;
    self.homeFeedTableView.backgroundColor = [UIColor lightTextColor];
}

-(void)setNavBtns {
    if(self.subFeed > 0){
        [self.profileBtn setTitle:@"" forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = nil;
        //self.navigationItem.hidesBackButton = true
    }
}

- (void)fetchBookmarked {
    PFRelation *relation = [self.user relationForKey:@"bookmarks"];
    void (^callbackForUse)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
            [self bookmarkCallback:posts errorMessage:error];
        };
    [self.manager relationQuery:relation getRelationInfo:callbackForUse];
}

- (void)bookmarkCallback:(NSArray *)posts errorMessage:(NSError *)error{
    if (error) {
        // There was an error
        NSLog(@"%@", error.localizedDescription);
    } else {
        // objects has all the Posts the current user liked.
        self.posts = posts;
        [self.homeFeedTableView reloadData];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self chooseFetch];
}

#pragma UITableView DataSource Method ::

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if([ self.dataArray count] ==0){
            return 0;
    }
    else {
        return [self.dataArray count]+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
    if(cell == nil){
            cell = [[HomeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
        }
    if (self.dataArray.count != 0) {
            if(indexPath.row < [self.dataArray count]){
                Post *post = self.posts[indexPath.row];
                cell.homeVC = self;
                [cell setPost:post];
            } else {
                 if (!self.noMoreResultsAvail) {
                        spinner.hidden =NO;
                        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
                        spinner.frame = CGRectMake(150, 10, 24, 50);
                        [cell addSubview:spinner];
                        if ([self.dataArray count] >= 10) {
                            [spinner startAnimating];
                        }
                 } else {
                        [spinner stopAnimating];
                        spinner.hidden=YES;
                        
                        UILabel* loadingLabel = [[UILabel alloc]init];
                        loadingLabel.font=[UIFont boldSystemFontOfSize:14.0f];
                        loadingLabel.textAlignment = UITextAlignmentLeft;
                        loadingLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
                        loadingLabel.numberOfLines = 0;
                        loadingLabel.text=@"No More Video Available";
                        loadingLabel.frame=CGRectMake(85,20, 302,25);
                        [cell addSubview:loadingLabel];
                    }
                }
    }

    
    
    
    
//    Post *post = self.posts[indexPath.row];
//    cell.homeVC = self;
//    [cell setPost:post];

    return cell;
}

#pragma UIScrollView Method::
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.loading) {
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height) {
            [self performSelector:@selector(loadDataDelayed) withObject:nil afterDelay:1];
        }
    }
}

#pragma UserDefined Method for generating data which are show in Table :::
-(void)loadDataDelayed{
    
    [self chooseFetch];
    [self.homeFeedTableView reloadData];
}


- (IBAction)didTapUserImage:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:sender];
    
}

-(void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    if(self.price != nil) {
        [postQuery whereKey:@"price" equalTo:self.price];
    }
    if(self.subFeed == 1) {
        [postQuery whereKey:@"author" equalTo:self.user];
        NSLog(@"%@", self.user);
    }
    postQuery.limit = 10;
    
    
    void (^callbackForUse)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
            [self postCallback:posts errorMessage:error];
        };
    [self.manager query:postQuery getObjects:callbackForUse];
    // fetch data asynchronously
    
}

- (void)postCallback:(NSArray *)posts errorMessage:(NSError *)error{
    if (posts != nil) {
        if(self.subFeed == 0) {
            // all posts in descending order
            self.allPosts = posts;
            PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
            // generate a query based on that relation
            PFQuery *filterQuery = [relation query];
            void (^callbackForFiltering)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
                    [self filterCallback:posts errorMessage:error];
                };
            [self.manager query:filterQuery getObjects:callbackForFiltering];
        } else {
            NSLog(@"%@", posts);
            self.posts = posts;
            [self.homeFeedTableView reloadData];
            [self.refreshControl endRefreshing];
        }
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)filterCallback:(NSArray *)users errorMessage:(NSError *)error{
    __block NSSet *followedUsers;
    __block NSMutableArray *followedPosts = [NSMutableArray new];
    if (users.count == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Find Foodies!"
                                                                                 message:@"Go to the magnifying glass in the upper left corner to look for foodies to follow for recommendations, ideas, and inspiration"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (users != nil) {
        // get users and make a mutable array of ids
        NSMutableArray *userIds = [NSMutableArray new];
        for (PFUser *user in users){
            [userIds addObject:user.objectId];
        }
        //make a set of the userids
        followedUsers = [NSSet setWithArray:[userIds copy]];
        //check if posts have an author you follow
        for (Post *post in self.allPosts) {
            //if so, add them to followed posts
            if([followedUsers containsObject:post.author.objectId]) {
                NSLog(@"%f", self.distance);
                if(self.distance != 0.000000) {
                    NSLog(@"%@", post.longitude);
                        CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:[post.latitude doubleValue] longitude:[post.longitude doubleValue]];
                    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:self.userLat longitude:self.userLong];
                    //[self setLatitude:[post.latitude floatValue] setLongitude:[post.longitude floatValue]];
                    CLLocationDistance distanceInMeters = [startLocation distanceFromLocation:restaurantLocation];
                    NSLog(@"%f", distanceInMeters/1609.344);
                    if(distanceInMeters/1609.344 <= self.distance) {
                        [followedPosts addObject:post];
                    }
                } else {
                    [followedPosts addObject:post];
                }
                
            }
        }
        self.posts = [followedPosts copy];
        self.dataArray =self.posts;
        
        //[self.homeFeedTableView reloadData];
        [self.refreshControl endRefreshing];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

-(void)chooseFetch {
    if(self.subFeed < 2) {
        [self fetchPosts];
    } else {
        [self fetchBookmarked];
    }
}
#pragma mark - delegate

- (void)passPrice:(FilterViewController *)controller didFinishEnteringPrice:(NSString *)price {
    self.price = price;
}
- (void)passDistance:(FilterViewController *)controller didFinishEnteringDistance:(double)distance {
    self.distance = distance;
}

- (void)passLongitude:(FilterViewController *)controller didFinishEnteringLongitude:(double)longitude {
    self.userLong = longitude;
}

- (void)passLatitude:(FilterViewController *)controller didFinishEnteringLatitude:(double)latitude {
    self.userLat = latitude;
}
- (void) refresh {
    [self chooseFetch];
}

#pragma mark - Navigation

- (IBAction)didTapProfile:(id)sender {
    NSLog(@"%i",self.subFeed);
    if(self.subFeed != 1) {
        [self performSegueWithIdentifier:@"feedProfileSegue" sender:nil];
    }
}

-(void)findUser {
    if(self.subFeed != 1) {
        [self performSegueWithIdentifier:@"findUserSegue" sender:nil];
    }
}
- (IBAction)didTapFindUser:(id)sender {
    NSLog(@"%i",self.subFeed);
    if(self.subFeed != 1) {
        [self performSegueWithIdentifier:@"findUserSegue" sender:nil];
    }
}
- (IBAction)didTapFilter:(id)sender {
    [self performSegueWithIdentifier:@"profileFilterSegue" sender:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"detailMapSegue"]) {
        UIButton *button = sender;
        HomeCell *cell = button.superview.superview;
        NSIndexPath *indexPath = [self.homeFeedTableView indexPathForCell:cell];
        //do cell for row at index path to get the dictionary
        Post *postToPass = self.posts[indexPath.row];
        DetailMapViewController *detailVC = [segue destinationViewController];
        detailVC.post = postToPass;
    }  else if ([[segue identifier] isEqualToString:@"feedProfileSegue"]) {
        PFUser *userToPass = [PFUser currentUser];
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileVC = (ProfileViewController  *)navController.topViewController;
        profileVC.user = userToPass;
    } else if ([[segue identifier] isEqualToString:@"profileSegue"]) {
        UIButton *button = sender;
        HomeCell *cell = button.superview.superview;
        NSIndexPath *indexPath = [self.homeFeedTableView indexPathForCell:cell];
        //do cell for row at index path to get the dictionary
        Post *post = self.posts[indexPath.row];
        PFUser *userToPass = post.author;
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileVC = (ProfileViewController  *)navController.topViewController;
        profileVC.user = userToPass;
    } else if ([[segue identifier] isEqualToString:@"findUserSegue"]) {
    } else if ([[segue identifier] isEqualToString:@"profileFilterSegue"]) {
        FilterViewController *filterVC = [segue destinationViewController];
        filterVC.delegate = self;
    }
}


@end
