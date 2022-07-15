//
//  HomeCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "APIManager.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface HomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *postImage;
@property (weak, nonatomic) IBOutlet UIButton *bookmark;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postCaption;
@property (weak, nonatomic) IBOutlet UIImageView *pinImage;
@property (weak, nonatomic) Post *post;
@property (weak, nonatomic) PFUser *author;
@property APIManager *manager;
@property BOOL bookmarked;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkView;

@end

NS_ASSUME_NONNULL_END
