//
//  TagsCell.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"
#import "Tag.h"
#import "TagsViewController.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface TagsCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *spacingLabel;
@property (weak, nonatomic) Tag *tag;
@property (strong, atomic) TagsViewController *parentVC;
@property APIManager *manager;
@property int unique;
@property int writeYourTag;

- (void) setUp;

@end

NS_ASSUME_NONNULL_END
