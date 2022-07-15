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
@property (nonatomic, strong) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *homeFeedTableView;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *profileBtn;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property NSString *price;
@property double userLat;
@property double userLong;
@property double distance;
@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.homeFeedTableView.delegate = self;
    self.homeFeedTableView.dataSource = self;
    
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(chooseFetch) forControlEvents:UIControlEventValueChanged];
    [self.homeFeedTableView insertSubview:self.refreshControl atIndex:0];
    [self setNavBtns];

}

-(void)setNavBtns {
    if(self.subFeed > 0){
        [self.profileBtn setTitle:@"" forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = nil;
        //self.navigationItem.hidesBackButton = true
    }
}

- (void)fetchBookmarked {
    NSLog(@"%@",self.user.username);
    PFRelation *relation = [self.user relationForKey:@"bookmarks"];
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable posts, NSError * _Nullable error) {
        if (error) {
            // There was an error
            NSLog(@"%@", error.localizedDescription);
        } else {
            // objects has all the Posts the current user liked.
            self.posts = posts;
            NSLog(@"%@",posts);
            [self.homeFeedTableView reloadData];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self chooseFetch];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
    Post *post = self.posts[indexPath.row];
    cell.homeVC = self;
    [cell setPost:post];
    

    return cell;
}


- (IBAction)didTapUserImage:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:sender];
    
}

//- (void)didTapPin:(id)sender {
//    [self performSegueWithIdentifier:@"detailMapSegue" sender:sender];
//}



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
    postQuery.limit = 20;
    __block NSArray *allPosts;
    __block NSSet *followedUsers;
    __block NSMutableArray *followedPosts = [NSMutableArray new];

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // all posts in descending order
            allPosts = posts;
            PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
            // generate a query based on that relation
            PFQuery *query = [relation query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (users != nil) {
                    // get users and make a mutable array of ids
                    NSMutableArray *userIds = [NSMutableArray new];
                    for (PFUser *user in users){
                        [userIds addObject:user.objectId];
                    }
                    //make a set of the userids
                    followedUsers = [NSSet setWithArray:[userIds copy]];
                    //check if posts have an author you follow
                    for (Post *post in allPosts) {
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
                    [self.homeFeedTableView reloadData];
                    [self.refreshControl endRefreshing];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    
   
}

-(void)chooseFetch {
    if(self.subFeed < 2) {
        [self fetchPosts];
    } else {
        [self fetchBookmarked];
    }
}
#pragma mark - delegate

//- (void)addItemViewController:(FilterViewController *)controller didFinishEnteringItem:(NSString *)item {
//     NSLog(@"This was returned from ViewControllerB %@", item);
//     NSLog(@"passed");
//    self.price = item;
// }

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
