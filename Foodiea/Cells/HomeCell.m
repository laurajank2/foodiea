//
//  HomeCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "HomeCell.h"
#import "DateTools.h"

@implementation HomeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapBookmark:(id)sender {
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"bookmarks"];
    [relation addObject:self.post];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // The post has been added to the user's likes relation.
            NSLog(@"success in making relation!");
        } else {
            // There was a problem, check error.description
            NSLog(@"Error posting image: %@", error);
        }
    }];
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
}

@end
