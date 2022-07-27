//
//  TagsViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "Tag.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@class TagsViewController;

@protocol TagsViewControllerDelegate <NSObject>
 - (void)tagsVC:(TagsViewController *)controller didFinishChoosingTag:(Tag *)tag;
@end

@interface TagsViewController : UIViewController

@property Boolean filter;
@property (atomic, strong) id <TagsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
