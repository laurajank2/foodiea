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
@dynamic hue;
@dynamic brightness;
@dynamic saturation;

+ (nonnull NSString *)parseClassName {
    return @"Tag";
}

+ (void) setTitle:(NSString * _Nullable) title setHue:(NSNumber * _Nullable)hue setBrightness:(NSNumber * _Nullable)brightness  setSaturation:(NSNumber * _Nullable)saturation withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Tag *newTag = [Tag new];
    newTag.title = title;
    newTag.hue = hue;
    newTag.saturation = saturation;
    newTag.brightness = brightness;
    
    [newTag saveInBackgroundWithBlock: completion];
}

@end
