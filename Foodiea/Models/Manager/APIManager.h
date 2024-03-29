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

+ (id)sharedManager;

- (id)init;

- (void)saveUserInfo: (PFUser * _Nullable) user;

- (void)query:(PFQuery * _Nullable)userQuery getObjects:(void (^)(NSArray *objects, NSError *error))callback;

- (void)relationQuery: (PFRelation * _Nullable)relation getRelationInfo:(void (^)(NSArray *objects, NSError *error))callback;

- (NSArray *)queryCurrentUserPosts: (PFQuery * _Nullable)postQuery;

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

- (NSString *)getGoogleKey;

- (NSString *)getAppId;

- (NSString *)getClientKey;

@end

NS_ASSUME_NONNULL_END
