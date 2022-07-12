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
    // Initialization code
    self.manager = [[APIManager alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)newPost {
    //maybe should be _post
    _post = newPost;
    //self.postImage.file = post[@"image"];
    //[self.postImage loadInBackground];
    self.postCaption.text = self.post[@"caption"];
    self.usernameLabel.text = self.post.author.username;
    NSDate *dateVisited = self.post[@"date"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM dd yyyy"];

    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];

    NSString *dateString = [formatter stringFromDate:dateVisited];

    self.dateLabel.text = dateString;
    self.priceLabel.text = self.post[@"price"];
    self.restaurantName.text = [NSString stringWithFormat:@"%@%@", @"Ate at ",  self.post[@"restaurantName"]];
    //image
    self.postImage.file = self.post[@"picture"];
    [self.postImage loadInBackground];
    self.userImage.file = self.post.author[@"profileImage"];
    [self.userImage loadInBackground];
    
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
            // do something with the array of object returned by the call
            NSLog(@"%@", posts);
            for (Post* potential in posts) {
                NSLog(@"potential");
                NSLog(@"%@", potential);
                NSLog(@"%@", potential.objectId);
                NSLog(@"%@", self.post.objectId);
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
    NSLog(@"bookmark query");
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer {
    //Code to handle the gesture
    NSLog(@"tapped");
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

//-(BOOL)isBookmarked {
//    __block BOOL isBookmarked = NO;
//    PFRelation *relation = [[PFUser currentUser] relationForKey:@"bookmarks"];
//    // generate a query based on that relation
//    PFQuery *query = [relation query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
//        if ([posts count] != 0) {
//            // do something with the array of object returned by the call
//            NSLog(@"%@", posts);
//            for (Post* potential in posts) {
//                if ([potential.objectId isEqualToString:self.post.objectId]) {
//                    isBookmarked = true;
//                    break;
//                }
//                // do stuff
//            }
//        } else {
//            NSLog(@"no bookmarks");
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//    return isBookmarked;
//}

@end
