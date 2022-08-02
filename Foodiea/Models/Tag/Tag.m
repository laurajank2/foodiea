//
//  Tag.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/20/22.
//

#import "Tag.h"

@implementation Tag

@dynamic title;
@dynamic createdAt;
@dynamic tagID;

+ (nonnull NSString *)parseClassName {
    return @"Tag";
}

+ (void) setTitle:(NSString * _Nullable) title setHue:(NSNumber * _Nullable)hue withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Tag *newTag = [Tag new];
    newTag.title = title;
    newTag.hue = hue;
    
    [newTag saveInBackgroundWithBlock: completion];
}

@end
