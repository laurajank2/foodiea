//
//  ProfileViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Post.h"
#import "ProfileCell.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *profilePosts;
@property (nonatomic, strong) NSArray *bookmarkPosts;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UICollectionView *profileFeed;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UIButton *fav1;
@property (weak, nonatomic) IBOutlet UIButton *fav2;
@property (weak, nonatomic) IBOutlet UIButton *fav3;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _user = [PFUser currentUser];
    [self filloutUser];
    [self fetchPosts];
}

-(void)filloutUser {
    [self.profileImage.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.profileImage.layer setBorderWidth: 1.5];
    // Do any additional setup after loading the view.
    self.profileFeed.dataSource = self;
    self.profileFeed.delegate = self;
    self.username.text = self.user.username;
    self.screenName.text = self.user[@"screenname"];
    self.bio.text = self.user[@"bio"];
    NSLog(@"@%@", self.user[@"fav_1"]);
    [self.fav1 setTitle:self.user[@"fav1"] forState:UIControlStateNormal];
    [self.fav2 setTitle:self.user[@"fav2"] forState:UIControlStateNormal];
    [self.fav3 setTitle:self.user[@"fav3"] forState:UIControlStateNormal];
    NSLog(@"profileImage");
    NSLog(@"%@", self.user[@"profileImage"]);
    self.profileImage.file = self.user[@"profileImage"];
    [self.profileImage loadInBackground];
    [self fetchPosts];
    
}

- (void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:self.user];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            self.profilePosts = posts;
            NSLog(@"the posts:");
            NSLog(@"%@", self.profilePosts);
            [self.profileFeed reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Collection View Requirements

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.profilePosts.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileCell *cell = [self.profileFeed dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
    Post *post = self.profilePosts[indexPath.row];
    //image
    cell.profileCellImage.file = post[@"picture"];
    [cell.profileCellImage loadInBackground];
    return cell;
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
