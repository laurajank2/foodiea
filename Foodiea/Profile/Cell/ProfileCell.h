//
//  ProfileCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface ProfileCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *profileCellImage;
@property (strong, nonatomic) ProfileViewController *profileVC;

@end

NS_ASSUME_NONNULL_END
