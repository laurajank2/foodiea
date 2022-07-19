//
//  FindUserCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/12/22.
//

#import "FindUserCell.h"
#import <Parse/Parse.h>

@implementation FindUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)fillCell {
    self.userImage.file = self.user[@"profileImage"];
    [self.userImage loadInBackground];
    self.username.text = self.user[@"username"];
    self.screenname.text = self.user[@"screenname"];
    self.location.text = self.user[@"location"];
}

@end
