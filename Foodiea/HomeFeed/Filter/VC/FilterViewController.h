//
//  FilterViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FilterViewController;
@class OBSlider;

@protocol FilterViewControllerDelegate <NSObject>
 - (void)passPrice:(FilterViewController *)controller didFinishEnteringPrice:(NSString *)price;
 - (void)passDistance:(FilterViewController *)controller didFinishEnteringDistance:(double)distance;
 - (void)passLongitude:(FilterViewController *)controller didFinishEnteringLongitude:(double)longitude;
 - (void)passLatitude:(FilterViewController *)controller didFinishEnteringLatitude:(double)latitude;
 - (void)passTags:(FilterViewController *)controller didFinishEnteringTags:(NSArray *)tags;
 - (void)refresh;
@end

@interface FilterViewController : UIViewController
@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
