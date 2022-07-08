//
//  APIManager.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/8/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

- (void)saveUserInfo: (PFUser * _Nullable) user;

@end

NS_ASSUME_NONNULL_END
