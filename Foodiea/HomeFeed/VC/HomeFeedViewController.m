//
//  HomeFeedViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "HomeFeedViewController.h"
#import <Parse/Parse.h>
#import "HomeCell.h"
#import "DetailMapViewController.h"
#import "ProfileViewController.h"


@interface HomeFeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *homeFeedTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.homeFeedTableView.delegate = self;
    self.homeFeedTableView.dataSource = self;
    [self fetchPosts];
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    [self.homeFeedTableView insertSubview:self.refreshControl atIndex:0];

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
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            self.posts = posts;
            NSLog(@"the posts:");
            NSLog(@"%@", self.posts);
            [self.homeFeedTableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Navigation

- (IBAction)didTapProfile:(id)sender {
    [self performSegueWithIdentifier:@"feedProfileSegue" sender:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"detailMapSegue"]) {
        UIButton *button = sender;
        NSLog(@"button");
        NSLog(@"%@", [button.superview.superview class]);
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
        NSLog(@"button");
        NSLog(@"%@", [button.superview.superview class]);
        HomeCell *cell = button.superview.superview;
        NSIndexPath *indexPath = [self.homeFeedTableView indexPathForCell:cell];
        //do cell for row at index path to get the dictionary
        Post *post = self.posts[indexPath.row];
        PFUser *userToPass = post.author;
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileVC = (ProfileViewController  *)navController.topViewController;
        profileVC.user = userToPass;
    }
}


@end
