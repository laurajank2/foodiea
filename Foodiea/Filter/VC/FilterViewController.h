//
//  FilterViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FilterViewController;

@protocol FilterViewControllerDelegate <NSObject>
 - (void)addItemViewController:(FilterViewController *)controller didFinishEnteringItem:(NSString *)item;
 @end

@interface FilterViewController : UIViewController

@property (nonatomic, weak) id <FilterViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
