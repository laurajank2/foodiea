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
@property (nonatomic, strong) NSMutableArray *postBox;
@property NSString *price;
@property double userLat;
@property double userLong;
@property double distance;
@property APIManager *manager;
//pagination
@property dispatch_group_t postGroup;
@property dispatch_group_t bookmarkGroup;
@property NSMutableDictionary<NSString*, NSNumber*> *followerPagesLoaded;
@property (nonatomic, assign) NSInteger screenPosts;
@property NSArray *lastAdded;
@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.homeFeedTableView.delegate = self;
    self.homeFeedTableView.dataSource = self;
    self.manager = [[APIManager alloc] init];
    //[self chooseFetch];
    
    //refresh control
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(chooseFetch) forControlEvents:UIControlEventValueChanged];
//    [self.homeFeedTableView insertSubview:self.refreshControl atIndex:0];
    [self setNavBtns];

}

-(void)setNavBtns {
    if(self.subFeed > 0){
        [self.profileBtn setTitle:@"" forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = nil;
        //self.navigationItem.hidesBackButton = true
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    //pagination
    
    [self chooseFetch];
}

-(void)chooseFetch {
    self.posts = nil;
    if(self.subFeed < 2) {
        self.screenPosts = 4;
        self.followerPagesLoaded = [NSMutableDictionary dictionary];
        _postBox = [NSMutableArray new];
        
        [self fetchFollowerPosts];
    } else {
        [self fetchBookmarked];
    }
}

#pragma mark - set up table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
    if(indexPath.row == self.screenPosts-1) {
        if(self.subFeed < 2) {
            self.screenPosts += 4;
            [self fetchFollowerPosts];
        } else {
            [self fetchBookmarked];
        }
        
    }
    Post *post = self.posts[indexPath.row];
    NSLog(@"%li", indexPath.row);
    NSLog(@"%@", post.caption);
    cell.homeVC = self;
    [cell setPost:post];

    return cell;
}


- (IBAction)didTapUserImage:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:sender];
    
}

#pragma mark - Get home posts by query



- (void)fetchBookmarked {
    PFRelation *relation = [self.user relationForKey:@"bookmarks"];
    PFQuery *bookmarksQuery = [relation query];
    bookmarksQuery.skip = self.screenPosts;
    void (^callbackForUse)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
            [self bookmarkCallback:posts errorMessage:error];
        };
    [self.manager query:bookmarksQuery getObjects:callbackForUse];
}

- (void)bookmarkCallback:(NSArray *)posts errorMessage:(NSError *)error{
    if (error) {
        // There was an error
        NSLog(@"%@", error.localizedDescription);
    } else {
        // objects has all the Posts the current user liked.
        if(self.posts != nil) {
            self.posts = [self.posts arrayByAddingObjectsFromArray:posts];
        } else {
            self.posts = posts;
        }
        self.screenPosts += self.posts.count;
    }
}

-(void)fetchFollowerPosts {
    if(self.subFeed == 0) {
        PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
        // generate a query based on that relation
        PFQuery *usersQuery = [relation query];
        void (^callbackForUsers)(NSArray *users, NSError *error) = ^(NSArray *users, NSError *error){
                [self followerCountCallback:users errorMessage:error];
            };
        [self.manager query:usersQuery getObjects:callbackForUsers];
    } else if (self.subFeed == 1) {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:self.user.objectId];
        void (^callbackForUsers)(NSArray *users, NSError *error) = ^(NSArray *users, NSError *error){
                [self followerCountCallback:users errorMessage:error];
            };
        [self.manager query:userQuery getObjects:callbackForUsers];
    }
    
}

- (void)followerCountCallback:(NSArray *)users errorMessage:(NSError *)error {
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
    } else if(users != nil) {
        int counter = 0;
        self.postGroup = dispatch_group_create();
        for (PFUser *user in users){
            dispatch_group_enter(self.postGroup);
            counter++;
            if(counter != users.count) {
                [self fetchPosts:user];
            } else {
                [self fetchPosts:user];
            }
        }
        
        dispatch_group_notify(self.postGroup, dispatch_get_main_queue(), ^{
            [self sortUserPosts];
            [self updateViewedPosts];
        });
    }
    
}

-(void)fetchPosts:(PFUser *)follower {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:follower];
    if(self.price != nil) {
        [postQuery whereKey:@"price" equalTo:self.price];
    }
    if(self.followerPagesLoaded[follower.objectId] != nil) {
        //might need to mess with types
        postQuery.skip = [self.followerPagesLoaded[follower.objectId] integerValue];
    } else {
        NSString *followerId = follower.objectId;
        NSNumber *zero = @0;
        [self.followerPagesLoaded setObject:zero forKey:followerId];
    }
    postQuery.limit = 4;
    void (^callbackForUse)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
        [self postCallback:posts follower:follower errorMessage:error];
        };
    [self.manager query:postQuery getObjects:callbackForUse];
}

- (void)postCallback:(NSArray *)posts follower:(PFUser *)follower errorMessage:(NSError *)error{
    if (posts != nil) {
        // all posts in descending order
        for(Post *post in posts) {
            if(self.distance != 0.000000) {
                CLLocation *restaurantLocation = [[CLLocation alloc] initWithLatitude:[post.latitude doubleValue] longitude:[post.longitude doubleValue]];
                CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:self.userLat longitude:self.userLong];
                //[self setLatitude:[post.latitude floatValue] setLongitude:[post.longitude floatValue]];
                CLLocationDistance distanceInMeters = [startLocation distanceFromLocation:restaurantLocation];
                if(distanceInMeters/1609.344 <= self.distance) {
                    [self.postBox addObject:post];
                }
            } else {
                [self.postBox addObject:post];
            }
        }
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
    dispatch_group_leave(self.postGroup);
}

-(void)setPostBookMark:(Post * _Nullable)post {
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"bookmarks"];
    // generate a query based on that relation
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if ([posts count] != 0) {
//            NSLog(@"%@", post.objectId);
//            NSLog(@"%@", posts);
            for (Post* potential in posts) {
                if ([potential.objectId isEqualToString:post.objectId]) {
                    post.currUserMarked = YES;
                    break;
                }
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        dispatch_group_leave(self.bookmarkGroup);
    }];
}

-(void)sortUserPosts {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                  ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.postBox sortedArrayUsingDescriptors:sortDescriptors];
    
    NSArray *smallArray = [sortedArray subarrayWithRange:NSMakeRange(0, MIN(4, sortedArray.count))];
    if(self.posts != nil) {
        self.posts = [self.posts arrayByAddingObjectsFromArray:smallArray];
    } else {
        self.posts = [sortedArray subarrayWithRange:NSMakeRange(0, MIN(4, sortedArray.count))];
    }
    _postBox = [NSMutableArray new];
    _lastAdded = smallArray;
    
    self.bookmarkGroup = dispatch_group_create();
    for(Post *post in smallArray) {
        dispatch_group_enter(self.bookmarkGroup);
        [self setPostBookMark:post];
    }
    
    dispatch_group_notify(self.bookmarkGroup, dispatch_get_main_queue(), ^{
        if(self.screenPosts != 4) {
            NSMutableArray *indiciesToAdd = [NSMutableArray new];
            for(int i = 0; i< MIN(4, smallArray.count); i++) {
                [indiciesToAdd addObject: [NSIndexPath indexPathForRow: self.screenPosts-4-1+i inSection: 0]];
            }
            [self.homeFeedTableView beginUpdates];
            [self.homeFeedTableView insertRowsAtIndexPaths:[indiciesToAdd copy] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.homeFeedTableView endUpdates];
        } else {
            [self.homeFeedTableView reloadData];
        }
    });
    
}

-(void)updateViewedPosts{
    for(Post *chosenPost in self.lastAdded) {
        int numLoaded = [self.followerPagesLoaded[chosenPost.author.objectId] integerValue] +1;
        self.followerPagesLoaded[chosenPost.author.objectId] = [NSNumber numberWithInt:numLoaded];
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
