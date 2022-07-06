//
//  HomeFeedViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "HomeFeedViewController.h"
#import <Parse/Parse.h>


@interface HomeFeedViewController ()
@property (nonatomic, strong) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *homeFeedTableView;

@end

@implementation HomeFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.homeFeedTableView.delegate = self;
//    self.homeFeedTableView.dataSource = self;
    
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.posts.count;
//}
//
//-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
//    Post *post = self.posts[indexPath.row];
//    [cell setPost:post];
//    //buttons
//
//    return cell;
//}
//-(void)fetchPosts {
//    PFQuery *postQuery = [Post query];
//    [postQuery orderByDescending:@"createdAt"];
//    [postQuery includeKey:@"author"];
//    postQuery.limit = 20;
//
//    // fetch data asynchronously
//    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
//        if (posts != nil) {
//            // do something with the array of object returned by the call
//            self.posts = posts;
//            NSLog(@"the posts:");
//            NSLog(@"%@", self.posts);
//            [self.postsTableView reloadData];
//            [self.refreshControl endRefreshing];
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//}

- (IBAction)didTapProfile:(id)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
