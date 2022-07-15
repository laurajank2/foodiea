//
//  HomeCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "HomeCell.h"
#import "DateTools.h"
#import "APIManager.h"
#import <Parse/Parse.h>

@implementation HomeCell


- (void)awakeFromNib {
    [super awakeFromNib];
    self.manager = [[APIManager alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)fetchUser:(NSString * _Nullable)objectId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:objectId];

    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
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
    }];
}

- (void)setPost:(Post *)newPost {
    _post = newPost;
    [self fetchUser:self.post.author.objectId];
    self.postCaption.text = self.post[@"caption"];
    NSLog(@"%@", self.author);
    NSDate *dateVisited = self.post[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM dd yyyy"];

    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

    NSString *dateString = [formatter stringFromDate:dateVisited];

    self.dateLabel.text = dateString;
    self.priceLabel.text = self.post[@"price"];
    self.restaurantName.text = [NSString stringWithFormat:@"%@%@", @"Ate at ",  self.post[@"restaurantName"]];
    //image
    self.postImage.file = self.post[@"picture"];
    [self.postImage loadInBackground];
    
    
    //double tap bookmark
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.bookmarkView addGestureRecognizer:gestureRecognizer];
    self.bookmarkView.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.numberOfTapsRequired = 2;
    
    
    //bookmark
    //goal: see if the user has the post in their bookmark relation
    // create a relation based on the authors key
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"bookmarks"];
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if ([posts count] != 0) {
            for (Post* potential in posts) {
                if ([potential.objectId isEqualToString:self.post.objectId]) {
                    NSLog(@"bookmarked");
                    NSString *imageName = @"bookmark-full.png";
                    UIImage *img = [UIImage imageNamed:imageName];
                    [self.bookmarkView setImage:img];
                    self.bookmarked = YES;
                    break;
                }
                // do stuff
            }
        } else {
            NSLog(@"no bookmarks");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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
    } else {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationForKey:@"bookmarks"];
        [relation addObject:self.post];
        [self.manager saveUserInfo:user];
        NSString *imageName = @"bookmark-full.png";
        UIImage *img = [UIImage imageNamed:imageName];
        [self.bookmarkView setImage:img];
        self.bookmarked = YES;
    }
}

@end
