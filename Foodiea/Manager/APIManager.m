//
//  APIManager.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/8/22.
//

#import "APIManager.h"
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

@end
