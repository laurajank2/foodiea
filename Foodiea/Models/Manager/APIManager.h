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

- (void)userQuery:(PFQuery * _Nullable)userQuery getUsers:(void (^)(NSArray *objects, NSError *error))callback;

- (void)queryPosts: (PFQuery * _Nullable)postQuery getPosts:(void (^)(NSArray *objects, NSError *error))callback;

- (void)relationQuery: (PFRelation * _Nullable)relation getRelationInfo:(void (^)(NSArray *objects, NSError *error))callback;

- (NSArray *)queryCurrentUserPosts: (PFQuery * _Nullable)postQuery;

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

- (NSString *)getGoogleKey;

- (NSString *)getAppId;

- (NSString *)getClientKey;

@end

NS_ASSUME_NONNULL_END
