//
//  ProfileViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import <UIKit/UIKit.h>
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@property BOOL followed;
-(void)setFollowed;
@end

NS_ASSUME_NONNULL_END
