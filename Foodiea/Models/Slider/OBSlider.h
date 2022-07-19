//
//  OBSlider.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBSlider : UISlider

@property (assign, nonatomic, readonly) float scrubbingSpeed;
@property (strong, nonatomic) NSArray *scrubbingSpeeds;
@property (strong, nonatomic) NSArray *scrubbingSpeedChangePositions;

@end

NS_ASSUME_NONNULL_END
