//
//  TagsCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TagsCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *spacingLabel;
@property UIViewController *parentVC;
@property APIManager *manager;
@end

NS_ASSUME_NONNULL_END
