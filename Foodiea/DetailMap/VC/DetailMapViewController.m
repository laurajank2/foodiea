//
//  DetailMapViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/11/22.
//

#import "DetailMapViewController.h"
#import "Post.h"
#import <GoogleMaps/GoogleMaps.h>

@interface DetailMapViewController ()
@end

@implementation DetailMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create a GMSCameraPosition that tells the map to display the
      // coordinate -33.86,151.20 at zoom level 6.
      GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[self.post.latitude doubleValue]
                                                              longitude:[self.post.longitude doubleValue]
                                                                   zoom:6];
      GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
      mapView.myLocationEnabled = YES;
      [self.view addSubview:mapView];

      // Creates a marker in the center of the map.
      GMSMarker *marker = [[GMSMarker alloc] init];
      marker.position = CLLocationCoordinate2DMake([self.post.latitude doubleValue], [self.post.longitude doubleValue]);
      marker.title = self.post.restaurantName;
      marker.snippet = self.post.formattedAddress;
      marker.map = mapView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
