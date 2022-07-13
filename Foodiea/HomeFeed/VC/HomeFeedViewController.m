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
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property NSString *price;
@property CLLocation *userLocation;
@property double distance;
@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self locationManagement];
    // Do any additional setup after loading the view.
    self.homeFeedTableView.delegate = self;
    self.homeFeedTableView.dataSource = self;
    NSLog(@"%f", self.distance);
    [self fetchPosts];
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.homeFeedTableView insertSubview:self.refreshControl atIndex:0];

}

-(void)locationManagement {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
    self.userLocation = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [self.userLocation coordinate];
    NSLog(@"%f", coordinate.latitude);
    NSLog(@"%f", coordinate.longitude);
    [self.locationManager stopUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self fetchPosts];
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
    [cell setPost:post];
    

    return cell;
}
- (IBAction)didTapUserImage:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:sender];
}

- (IBAction)didTapPin:(id)sender {
    [self performSegueWithIdentifier:@"detailMapSegue" sender:sender];
}

-(void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    if(self.price != nil) {
        [postQuery whereKey:@"price" equalTo:self.price];
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
                            if(self.distance != 0.000000) {
                                NSLog(@"%@", post.longitude);
                                    CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:[post.latitude doubleValue] longitude:[post.longitude doubleValue]];
                                CLLocation *restaurantSecondLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
                                //[self setLatitude:[post.latitude floatValue] setLongitude:[post.longitude floatValue]];
                                CLLocationDistance distanceInMeters = [restaurantSecondLocation distanceFromLocation:restaurantLocation];

                                NSLog(@"%f", distanceInMeters);
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
    NSLog(@"This was returned from ViewControllerB %f", self.distance);
    NSLog(@"This was returned from ViewControllerB %f", distance);
}

#pragma mark - Navigation

- (IBAction)didTapProfile:(id)sender {
    [self performSegueWithIdentifier:@"feedProfileSegue" sender:nil];
}
- (IBAction)didTapFindUser:(id)sender {
    [self performSegueWithIdentifier:@"findUserSegue" sender:nil];
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
        NSLog(@"find user");
    } else if ([[segue identifier] isEqualToString:@"profileFilterSegue"]) {
        FilterViewController *filterVC = [segue destinationViewController];
        filterVC.delegate = self;
    }
}


@end
