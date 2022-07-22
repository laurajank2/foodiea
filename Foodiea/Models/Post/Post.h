//
//  Post.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@import GooglePlaces;

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *picture;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSString *formattedAddress;
@property BOOL currUserMarked;


+ (void) postUserImage: ( UIImage * _Nullable )image restaurantName: (NSString * _Nullable )name restaurantPrice: (NSString * _Nullable )price withCaption: ( NSString * _Nullable )caption postDate: ( NSDate * _Nullable )date postLongitude: (NSNumber * _Nullable) longitude postLatitude: (NSNumber * _Nullable) latitude postAddress: (NSString * _Nullable) address postTags: (NSArray * _Nullable)tags withCompletion: (PFBooleanResultBlock  _Nullable)completion;



@end

NS_ASSUME_NONNULL_END
