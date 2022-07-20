//
//  TagsCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import "TagsCell.h"
#import "Tag.h"

@implementation TagsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self doubleTap];
}

- (void)doubleTap {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.spacingLabel addGestureRecognizer:gestureRecognizer];
    self.spacingLabel.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.numberOfTapsRequired = 2;
}

//+ (void) setTitle:(NSString * _Nullable) title withCompletion: (PFBooleanResultBlock  _Nullable)completion
- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer {
    [Tag setTitle:self.titleLabel.text
     withCompletion: ^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            NSLog(@"Successfully posted image!");
            [self.parentVC dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            NSLog(@"Error posting image: %@", error);
        }
    }];
}

@end
