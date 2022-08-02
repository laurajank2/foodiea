//
//  OutsideTap.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "TagsCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface OutsideTap : UITapGestureRecognizer

@property (nonatomic, strong) TagsCell *avoidCell;

@end

NS_ASSUME_NONNULL_END
