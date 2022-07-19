//
//  FindUserCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/12/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface FindUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *screenname;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property PFUser *user;

- (void)fillCell;

@end

NS_ASSUME_NONNULL_END
