//
//  PlacesViewController.h
//  Foodiea
//
//  Created by Laura Jankowski on 7/11/22.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import GooglePlaces;
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface PlacesViewController : UIViewController
// An array to hold the list of likely places.
@property NSMutableArray<GMSPlace *> *likelyPlaces;

// The currently selected place.
@property GMSPlace * _Nullable selectedPlace;

@end

NS_ASSUME_NONNULL_END
