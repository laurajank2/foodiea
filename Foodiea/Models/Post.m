//
//  Post.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "Post.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic picture;
@dynamic price;
@dynamic createdAt;
@dynamic restaurantName;
@dynamic date;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserImage: ( UIImage * _Nullable )image restaurantName: (NSString * _Nullable )name restaurantPrice: (NSString * _Nullable )price withCaption: ( NSString * _Nullable )caption postDate: ( NSDate * _Nullable )date withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.picture = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.price = price;
    newPost.restaurantName = name;
    newPost.date = date;
    
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
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
