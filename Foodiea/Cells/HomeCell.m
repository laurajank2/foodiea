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

- (void)setPost:(Post *)newPost {
    //maybe should be _post
    _post = newPost;
    //self.postImage.file = post[@"image"];
    //[self.postImage loadInBackground];
    self.postCaption.text = self.post[@"caption"];
    self.usernameLabel.text = self.post.author.username;
    self.dateLabel.text = [NSString stringWithFormat:@"%@%@%@", @"Created ",  self.post.createdAt.shortTimeAgoSinceNow, @" ago"];
    //image
    self.postImage.file = self.post[@"image"];
    self.priceLabel.text = self.post[@"price"];
    
    [self.postImage loadInBackground];
    self.userImage.file = self.post.author[@"profileImage"];
    [self.userImage loadInBackground];
}

@end
