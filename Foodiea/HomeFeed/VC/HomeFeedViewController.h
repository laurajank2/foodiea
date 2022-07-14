//
//  HomeFeedViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import Parse;
NS_ASSUME_NONNULL_BEGIN

@interface HomeFeedViewController : UIViewController <CLLocationManagerDelegate>
@property int subFeed;
@property PFUser *user;
@end

NS_ASSUME_NONNULL_END
