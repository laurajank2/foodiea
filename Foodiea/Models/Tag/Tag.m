//
//  Tag.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import "Tag.h"

@implementation Tag

@dynamic title;

+ (nonnull NSString *)parseClassName {
    return @"Tag";
}

+ (void) setTitle:(NSString * _Nullable) title withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Tag *newTag = [Tag new];
    newTag.title = title;
    
    [newTag saveInBackgroundWithBlock: completion];
}

@end
