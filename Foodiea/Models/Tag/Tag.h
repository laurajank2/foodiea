//
//  Tag.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tag : PFObject <PFSubclassing>

@property (nonatomic, strong) NSString *title;

+ (void) setTitle:(NSString * _Nullable) title withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
