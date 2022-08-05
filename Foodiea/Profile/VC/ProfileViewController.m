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
#import "APIManager.h"
#import "HomeFeedViewController.h"
#import "FontAwesomeKit/FontAwesomeKit.h"
#import "SCLAlertView.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *profilePosts;
@property (nonatomic, strong) NSArray *bookmarkPosts;
@property (weak, nonatomic) IBOutlet UIButton *rightNavBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *profileFeed;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UIButton *fav1;
@property (weak, nonatomic) IBOutlet UIButton *fav2;
@property (weak, nonatomic) IBOutlet UIButton *fav3;
@property (weak, nonatomic) IBOutlet UILabel *expertLoc;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (weak, nonatomic) IBOutlet UILabel *favslabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UIImageView *pencilImg;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkImg;
@property int penOrMark;
@property APIManager *manager;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[APIManager alloc] init];
    
    [self filloutUser];
    [self setFollowed];
    [self fetchPosts];
    [self setFavs];
    
}


-(void)filloutUser {
    [self.profileImage.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.profileImage.layer setBorderWidth: 1.5];
    self.profileFeed.dataSource = self;
    self.profileFeed.delegate = self;
    self.username.text = self.user.username;
    self.screenName.text = self.user[@"screenname"];
    self.bio.text = self.user[@"bio"];
    self.expertLoc.text = self.user[@"location"];
    NSLog(@"%@", self.user[@"followingCount"]);
    if(self.user[@"followingCount"] == nil || [self.user[@"followingCount"] isEqualToNumber:@0]) {
        [self fetchFollowingCount];
    } else {
        self.followingCount.text = [NSString stringWithFormat:@"%@", self.user[@"followingCount"]];
    }
    [self.fav1 setTitle:self.user[@"fav1"] forState:UIControlStateNormal];
    [self.fav2 setTitle:self.user[@"fav2"] forState:UIControlStateNormal];
    [self.fav3 setTitle:self.user[@"fav3"] forState:UIControlStateNormal];
    self.profileImage.file = self.user[@"profileImage"];
    [self.profileImage loadInBackground];
    [self fetchPosts];
    self.penOrMark = 0;
    self.pencilImg.image = [UIImage imageNamed:@"pencil.fill.png"];
}

-(void)setFavs {
    if([self.fav1.currentTitle isEqualToString:@""] || self.fav1.currentTitle == nil) {
        self.fav1.hidden = YES;
        self.fav1.userInteractionEnabled = NO;
    } else if (![self.fav1.currentTitle isEqualToString:@""] && self.fav1.currentTitle != nil) {
        self.fav1.hidden = NO;
        self.fav1.userInteractionEnabled = YES;
    }
    
    if([self.fav2.currentTitle isEqualToString:@""] || self.fav2.currentTitle == nil) {
        self.fav2.hidden = YES;
        self.fav2.userInteractionEnabled = NO;
    } else if (![self.fav2.currentTitle isEqualToString:@""] && self.fav2.currentTitle != nil) {
        self.fav2.hidden = NO;
        self.fav2.userInteractionEnabled = YES;
    }
    
    if([self.fav3.currentTitle isEqualToString:@""] || self.fav3.currentTitle == nil) {
        self.fav3.hidden = YES;
        self.fav3.userInteractionEnabled = NO;
    } else if (![self.fav3.currentTitle isEqualToString:@""] && self.fav3.currentTitle != nil) {
        self.fav3.hidden = NO;
        self.fav3.userInteractionEnabled = YES;
    }
    
    if(self.fav1.hidden && self.fav2.hidden && self.fav3.hidden) {
        self.favslabel.hidden = YES;
    } else {
        self.favslabel.hidden = NO;
    }
}

-(void)setRightNavBtn {
    if ([self.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        //set right nav btn
        FAKFontAwesome *cogIcon = [FAKFontAwesome cogIconWithSize:30];
        [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        UIImage *rightImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
        cogIcon.iconFontSize = 30;
        UIImage *rightLandscapeImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:rightImage
                           landscapeImagePhone:rightLandscapeImage
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(handleNav)];
        //set post btn
        FAKFontAwesome *plusIcon = [FAKFontAwesome plusSquareOIconWithSize:30];
        [plusIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
        UIImage *plusImage = [plusIcon imageWithSize:CGSizeMake(30, 30)];
        [self.postBtn setImage:plusImage forState:UIControlStateNormal];
        self.postBtn.userInteractionEnabled = YES;
    } else {
        //set right nav btn
        if(self.followed) {
            [self.rightNavBtn setTitle:@"Unfollow" forState:UIControlStateNormal];
        } else {
            [self.rightNavBtn setTitle:@"Follow" forState:UIControlStateNormal];
        }
        
        //set post btn
        self.postBtn.userInteractionEnabled = NO;
        
    }
}

- (void) handleNav {
    if ([self.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
    } else {
        if (self.followed) {
            self.followed = NO;
            [self setRightNavBtn];
            PFUser *user = [PFUser currentUser];
            PFRelation *relation = [user relationForKey:@"following"];
            [relation removeObject:self.user];
            
            //set following count
            if(self.user[@"followingCount"] != nil) {
                NSNumber *followingCount = [PFUser currentUser][@"followingCount"];
                double newCount = [followingCount integerValue] - 1;
                [PFUser currentUser][@"followingCount"] = [NSNumber numberWithDouble:newCount];
            } else {
                [self fetchFollowingCount];
            }
            
            [self.manager saveUserInfo:user];
            
            
        } else {
            self.followed = YES;
            [self setRightNavBtn];
            PFUser *user = [PFUser currentUser];
            PFRelation *relation = [user relationForKey:@"following"];
            [relation addObject:self.user];
            NSNumber *followingCount = [PFUser currentUser][@"followingCount"];
            double newCount = [followingCount integerValue] + 1;
            [PFUser currentUser][@"followingCount"] = [NSNumber numberWithDouble:newCount];
            [self.manager saveUserInfo:user];
            
        }
        
    }
}

- (void)fetchFollowingCount {
    PFRelation *relation = [self.user relationForKey:@"following"];
    PFQuery *usersQuery = [relation query];
    void (^callbackForUsers)(NSArray *users, NSError *error) = ^(NSArray *users, NSError *error){
            [self followerCountCallback:users errorMessage:error];
        };
    [self.manager query:usersQuery getObjects:callbackForUsers];
}

- (void)followerCountCallback:(NSArray *)users errorMessage:(NSError *)error {
    if (users.count == 0) {
        self.followingCount.text = @"0";
    } else if(users != nil) {
        int counter = 0;
        for (PFUser *user in users){
            counter++;
        }
        self.user[@"followingCount"] = [NSNumber numberWithInt:counter];
        self.followingCount.text = [NSString stringWithFormat:@"%d",counter];
        [self.manager saveUserInfo:[PFUser currentUser]];
    }
    
}


- (IBAction)tapTopRight:(id)sender {
    [self handleNav];
}

- (IBAction)didTapBookmark:(id)sender {
    [self fetchBookmarked];
    self.bookmarkImg.image = [UIImage imageNamed:@"bookmark-full.png"];
    self.pencilImg.image = [UIImage imageNamed:@"pencil.png"];
    self.penOrMark = 1;
}
- (IBAction)didTapPencil:(id)sender {
    [self fetchPosts];
    self.bookmarkImg.image = [UIImage imageNamed:@"bookmark-empty.png"];
    self.pencilImg.image = [UIImage imageNamed:@"pencil.fill.png"];
    self.penOrMark = 0;
}

- (void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:self.user];
    postQuery.limit = 20;

    void (^callbackForUse)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
            [self postCallback:posts errorMessage:error];
        };
    [self.manager query:postQuery getObjects:callbackForUse];
    
}

- (void)postCallback:(NSArray *)posts errorMessage:(NSError *)error{
    if (posts != nil) {
        self.profilePosts = posts;
        [self.profileFeed reloadData];
        
    } else {
        NSLog(@"%@", error.localizedDescription);
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
        self.profilePosts = posts;
        [self.profileFeed reloadData];
    }
}

#pragma mark - Feed Collection View Requirements

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.profilePosts.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileCell *cell = [self.profileFeed dequeueReusableCellWithReuseIdentifier:@"ProfileCell" forIndexPath:indexPath];
    Post *post = self.profilePosts[indexPath.row];
    //image
    cell.profileCellImage.file = post[@"picture"];
    [cell.profileCellImage loadInBackground];
    cell.profileVC = self;
    return cell;
}

-(void)setFollowed {
    self.followed = NO;
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if ([posts count] != 0) {
            Boolean navSet = NO;
            for (PFUser* potential in posts) {
                if ([potential.objectId isEqualToString:self.user.objectId]) {
                    self.followed = YES;
                    navSet = YES;
                    [self setRightNavBtn];
                    break;
                }
            }
            if(!navSet) {
                [self setRightNavBtn];
            }
        } else {
            [self setRightNavBtn];
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"profileHomeSegue"]) {
        HomeFeedViewController *feedVC = [segue destinationViewController];
        feedVC.subFeed = 1 + self.penOrMark;
        feedVC.user = self.user;
    }
}

- (IBAction)didTapFav1:(id)sender {
    if ((![self.user[@"fav1Link"] isEqualToString:@""] && self.user[@"fav1Link"] != nil)){
        [[UIApplication sharedApplication] openURL:[NSURL
        URLWithString:self.user[@"fav1Link"]]];
    } else {
        [self missingLink];
    }
    
}

- (IBAction)didTapFav2:(id)sender {
    if ((![self.user[@"fav2Link"] isEqualToString:@""] && self.user[@"fav2Link"] != nil)){
        [[UIApplication sharedApplication] openURL:[NSURL
        URLWithString:self.user[@"fav2Link"]]];
    } else {
        [self missingLink];
    }
}
- (IBAction)didTapFav3:(id)sender {
    if ((![self.user[@"fav3Link"] isEqualToString:@""] && self.user[@"fav3Link"] != nil)){
        [[UIApplication sharedApplication] openURL:[NSURL
        URLWithString:self.user[@"fav3Link"]]];
    } else {
        [self missingLink];
    }
}

-(void)missingLink {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self title:@"Missing Link" subTitle:@"This user has not added a link for this favorite." closeButtonTitle:@"OK" duration:0.0f];
}

-(void)viewDidAppear:(BOOL)animated{
    [self filloutUser];
    [self setFollowed];
    [self fetchPosts];
    [self setFavs];
    if(self.user == [PFUser currentUser]) {
        if((![self.user[@"fav1"] isEqualToString:@""] && self.user[@"fav1"] != nil) && ([self.user[@"fav1Link"] isEqualToString:@""] || self.user[@"fav1Link"] == nil)) {
            [self showLinkAlert:@"1"];
        }
        if((![self.user[@"fav2"] isEqualToString:@""] && self.user[@"fav2"] != nil) && ([self.user[@"fav2Link"] isEqualToString:@""] || self.user[@"fav2Link"] == nil)) {
            [self showLinkAlert:@"2"];
        }
        if((![self.user[@"fav3"] isEqualToString:@""] && self.user[@"fav3"] != nil) && ([self.user[@"fav3Link"] isEqualToString:@""] || self.user[@"fav3Link"] == nil)) {
            [self showLinkAlert:@"3"];
        }
    }
    
}

-(void)showLinkAlert:(NSString * _Nullable)favNum {
    
    NSString *title = @"Case of the Missing Link";
    NSString *part1 = @"You have not set a link for your fav";
    NSString *part2 = @"! Without one, other users will not be able to find your favorite spot! Please enter a link including http://";
    NSString *message = [NSString stringWithFormat:@"%@%@%@", part1, favNum, part2];
    NSString *cancel = @"Cancel";
    NSString *done = @"Done";
    
    SCLALertViewTextFieldBuilder *textField = [SCLALertViewTextFieldBuilder new].title(@"Link");
    SCLALertViewButtonBuilder *doneButton = [SCLALertViewButtonBuilder new].title(done)
    .validationBlock(^BOOL{
        NSString *link = [textField.textField.text copy];
        return [self checkLink:link];
    })
    .actionBlock(^{
        NSString *link = [textField.textField.text copy];
        NSString *fav = @"fav";
        NSString *linkString = @"Link";
        NSString *entry = [NSString stringWithFormat:@"%@%@%@", fav, favNum, linkString];
        self.user[entry] = link;
        [self.manager saveUserInfo:self.user];
    });
    
    SCLAlertViewBuilder *builder = [SCLAlertViewBuilder new]
    .showAnimationType(SCLAlertViewShowAnimationFadeIn)
    .hideAnimationType(SCLAlertViewHideAnimationFadeOut)
    .shouldDismissOnTapOutside(NO)
    .addTextFieldWithBuilder(textField)
    .addButtonWithBuilder(doneButton);
    
    FAKFontAwesome *linkIcon = [FAKFontAwesome linkIconWithSize:30];
    [linkIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *linkImage = [linkIcon imageWithSize:CGSizeMake(30, 30)];
    
    SCLAlertViewShowBuilder *showBuilder = [SCLAlertViewShowBuilder new]
    .style(SCLAlertViewStyleCustom)
    .image(linkImage)
    .color([UIColor blueColor])
    .title(title)
    .subTitle(message)
    .closeButtonTitle(cancel)
    .duration(0.0f);

    [showBuilder showAlertView:builder.alertView onViewController:self];
}

-(BOOL)checkLink:(NSString * _Nullable)link {
    NSURL *url = [NSURL URLWithString:link];
    if (url && url.scheme && url.host)
    {
        return YES;
    } else {
        return NO;
    }
}



@end
