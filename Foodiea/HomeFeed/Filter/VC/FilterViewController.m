//
//  FilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import "FilterViewController.h"
#import <math.h>
#import "OBSlider.h"
@import GooglePlaces;

@interface FilterViewController () <GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property (weak, nonatomic) IBOutlet OBSlider *distanceCtrl;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *min;
@property (weak, nonatomic) IBOutlet UILabel *max;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property NSString *price;
@property double distance;
@property double startLatitude;
@property double startLongitude;

@end

@implementation FilterViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeButton];
}

- (IBAction)onPriceChange:(id)sender {
    self.price = [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex];
    
}
- (IBAction)onDistanceChange:(id)sender {
    NSNumberFormatter *twoDecimalPlacesFormatter = [[NSNumberFormatter alloc] init];
    [twoDecimalPlacesFormatter setMaximumFractionDigits:2];
    [twoDecimalPlacesFormatter setMinimumFractionDigits:0];
    NSString *distanceString = [twoDecimalPlacesFormatter stringFromNumber:[NSNumber numberWithFloat: self.distanceCtrl.value]];
    self.distance = [distanceString doubleValue];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@%@", distanceString, @" miles"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.delegate passPrice:self didFinishEnteringPrice:self.price];
    [self.delegate passDistance:self didFinishEnteringDistance:self.distance];
    [self.delegate passLongitude:self didFinishEnteringLongitude:self.startLongitude];
    [self.delegate passLatitude:self didFinishEnteringLatitude:self.startLatitude];
    [self.delegate refresh];
    
}

// Add a button to the view.
- (void)makeButton{
    [self.btnLaunchAc addTarget:self
               action:NSSelectorFromString(@"autocompleteClicked") forControlEvents:UIControlEventTouchUpInside];
}

// Present the autocomplete view controller when the button is pressed.
- (void)autocompleteClicked {
  GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
  acController.delegate = self;

  // Specify the place data types to return.
  GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPlaceID | GMSPlaceFieldFormattedAddress | GMSPlaceFieldCoordinate);
  acController.placeFields = fields;

  // Specify a filter.
  _filter = [[GMSAutocompleteFilter alloc] init];
  _filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
  acController.autocompleteFilter = _filter;

  // Display the autocomplete view controller.
  [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.startLatitude = place.coordinate.latitude;
    self.startLongitude = place.coordinate.longitude;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
    }

    // User canceled the operation.
    - (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
-(void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
