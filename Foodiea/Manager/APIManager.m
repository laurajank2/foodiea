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

- (NSArray *)queryPosts: (PFQuery * _Nullable)postQuery {
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

@end
