//
//  HomeCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "HomeCell.h"
#import "DateTools.h"
#import "APIManager.h"
#import "TagsCell.h"
#import "Tag.h"
#import <ChameleonFramework/Chameleon.h>
#import <Parse/Parse.h>
@interface HomeCell() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *tagsArray;
@property NSString *objectId;

@end
@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.manager = [APIManager sharedManager];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)fetchUser:(NSString * _Nullable)objectId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:objectId];

    void (^callbackForUse)(NSArray *users, NSError *error) = ^(NSArray *users, NSError *error){
            [self callback:users errorMessage:error];
        };
    [self.manager query:userQuery getObjects:callbackForUse];
}

- (void)callback:(NSArray *)users errorMessage:(NSError *)error{
    if (users != nil) {
        // do something with the array of object returned by the call
        for (PFUser *currUser in users) {
            self.author = currUser;
        }
        self.usernameLabel.text = self.author.username;
        self.userImage.file = self.author[@"profileImage"];
        [self.userImage loadInBackground];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (IBAction)didTouchPin:(id)sender {
    [self animatePinSmall];
}
- (IBAction)didTapPin:(id)sender {
    [UIView animateWithDuration:0.15
        animations:^{
            [self animatePinBig];
        } completion:^(BOOL finished) {
            [self.homeVC performSegueWithIdentifier:@"detailMapSegue" sender:sender];
        }
    ];
}

-(void) animatePinBig{
    CABasicAnimation *big = [CABasicAnimation animationWithKeyPath: @"transform.scale.y"];
    big.fromValue = @0.25;
    big.toValue = @0.1;
    self.pinImage.image = [self resizeImageWithNewHeight:self.pinImage.image newWidth:self.pinImage.image.size.width*4];
    [self.pinImage.layer addAnimation:big forKey:@"transform.scale.y"];
}

-(void) animatePinSmall {
    CABasicAnimation *small = [CABasicAnimation animationWithKeyPath: @"transform.scale.y"];
    small.fromValue = @1;
    small.toValue = @0.25;
    small.duration = 0.15;
    [self.pinImage.layer addAnimation:small forKey:@"transform.scale.y"];
    self.pinImage.image = [self resizeImageWithNewHeight:self.pinImage.image newWidth:self.pinImage.image.size.width*0.25];
}

-(UIImage *)resizeImageWithNewHeight:(UIImage *)image newWidth:(CGFloat)nheight {

    float scale = nheight / image.size.height;

    float newWidth = image.size.width * scale;

    UIGraphicsBeginImageContext(CGSizeMake(nheight, newWidth));

    [image drawInRect:CGRectMake(0, 0, nheight, newWidth)];

    UIImage *nImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return nImage;

}

- (void)setPost:(Post *)newPost {
    _post = newPost;
    [self fetchUser:self.post.author.objectId];
    self.objectId = self.post.objectId;
    self.postCaption.text = self.post[@"caption"];
    NSDate *dateVisited = self.post[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM dd yyyy"];

    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

    NSString *dateString = [formatter stringFromDate:dateVisited];

    self.dateLabel.text = dateString;
    self.priceLabel.text = self.post[@"price"];
    self.restaurantName.text = [NSString stringWithFormat:@"%@%@", @"Ate at ",  self.post[@"restaurantName"]];
    self.nameBackground.text = self.post[@"restaurantName"];
    //image
    [self.userImage.layer setCornerRadius:self.userImage.frame.size.height/2];
    self.postImage.file = self.post[@"picture"];
    [self.postImage loadInBackground];
    
    
    //double tap bookmark
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.bookmarkView addGestureRecognizer:gestureRecognizer];
    self.bookmarkView.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.numberOfTapsRequired = 2;
    
    
    if(self.post.currUserMarked) {
        NSString *imageName = @"bookmark-full.png";
        UIImage *img = [UIImage imageNamed:imageName];
        [self.bookmarkView setImage:img];
        self.bookmarked = YES;
    } else {
        NSString *imageName = @"bookmark-empty.png";
        UIImage *img = [UIImage imageNamed:imageName];
        [self.bookmarkView setImage:img];
        self.bookmarked = NO;
    }
    
    [self fetchTags];
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer {
    if(self.bookmarked) {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationForKey:@"bookmarks"];
        [relation removeObject:self.post];
        [self.manager saveUserInfo:user];
        NSString *imageName = @"bookmark-empty.png";
        UIImage *img = [UIImage imageNamed:imageName];
        [self.bookmarkView setImage:img];
        self.bookmarked = NO;
        self.post.currUserMarked = NO;
    } else {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationForKey:@"bookmarks"];
        [relation addObject:self.post];
        [self.manager saveUserInfo:user];
        NSString *imageName = @"bookmark-full.png";
        UIImage *img = [UIImage imageNamed:imageName];
        [self.bookmarkView setImage:img];
        self.bookmarked = YES;
        self.post.currUserMarked = YES;
    }
}

#pragma mark - Tag Collection View

-(void) fetchTags {
    PFRelation *relation = [self.post relationForKey:@"tags"];
    // generate a query based on that relation
    PFQuery *tagsQuery = [relation query];
    void (^callbackForTags)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
            [self tagsCallback:tags errorMessage:error];
        };
    [self.manager query:tagsQuery getObjects:callbackForTags];
}

- (void)tagsCallback:(NSArray *)tags errorMessage:(NSError *)error{
    if (tags != nil) {
        self.tagsArray = tags;
        [self.tagsView setDataSource:self];
        [self.tagsView setDelegate:self];
        [self.tagsView reloadData];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
    
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.tagsArray.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagsView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.tagsArray[indexPath.row];
    cell.tag = tag;
    cell.writeYourTag = 0;
    cell.hue = [cell.tag.hue doubleValue];
    [cell setUp];
    return cell;
}


@end
