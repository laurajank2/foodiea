//
//  SearchFilterViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/18/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SearchFilterViewController;
@protocol SearchFilterViewControllerDelegate <NSObject>
 - (void)passPrice:(SearchFilterViewController *)controller didFinishEnteringPrice:(NSString *)price;
 - (void)passSearch:(SearchFilterViewController *)controller didFinishEnteringSearch:(NSString *)searchBy;
 - (void)refresh;
@end
@interface SearchFilterViewController : UIViewController

@property (nonatomic, weak) id <SearchFilterViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
