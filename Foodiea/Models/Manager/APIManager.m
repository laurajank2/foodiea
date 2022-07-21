//
//  APIManager.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/8/22.
//

#import "APIManager.h"
#import "Post.h"
#import <Parse/Parse.h>
@implementation APIManager

- (void)saveUserInfo: (PFUser * _Nullable) user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
              NSLog(@"Error posting: %@", error.localizedDescription);
         }
         else{
             NSLog(@"Successfully posted");
         }
    }];
}

#pragma mark - Parse Queries

- (void)query:(PFQuery * _Nullable)userQuery getObjects:(void (^)(NSArray *objects, NSError *error))callback {
    [userQuery findObjectsInBackgroundWithBlock:callback];
}

- (void)relationQuery: (PFRelation * _Nullable)relation getRelationInfo:(void (^)(NSArray *objects, NSError *error))callback {
    [[relation query] findObjectsInBackgroundWithBlock:callback];
}

- (NSArray *)queryCurrentUserPosts: (PFQuery * _Nullable)postQuery {
    __block NSArray *profilePosts;
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // do something with the array of object returned by the call
            profilePosts = posts;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    return profilePosts;
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

#pragma mark - keys

- (NSString *)getGoogleKey{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *key = [dict objectForKey: @"GOOGLE_API_KEY"];
    
    return key;
}

- (NSString *)getAppId{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *appId = [dict objectForKey: @"app_id"];
    
    return appId;
}

- (NSString *)getClientKey{
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *cKey = [dict objectForKey: @"client_key"];
    
    return cKey;
}

@end
