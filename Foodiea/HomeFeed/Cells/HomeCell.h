//
//  HomeCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "APIManager.h"
#import "HomeFeedViewController.h"
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
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property (weak, nonatomic) IBOutlet UILabel *nameBackground;
@property (weak, nonatomic) Post *post;
@property (weak, nonatomic) PFUser *author;
@property APIManager *manager;
@property BOOL bookmarked;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bookmarkView;
@property HomeFeedViewController *homeVC;

@end

NS_ASSUME_NONNULL_END
