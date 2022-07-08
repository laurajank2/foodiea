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
