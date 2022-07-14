//
//  HomeFeedViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeFeedViewController : UIViewController <CLLocationManagerDelegate>
@property int subFeed;
@end

NS_ASSUME_NONNULL_END
