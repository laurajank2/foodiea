//
//  FilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import "FilterViewController.h"
#import "StepSlider.h"
@import GooglePlaces;

@interface FilterViewController () <GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property (weak, nonatomic) IBOutlet UISlider *distanceCtrl;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet StepSlider *coolSlider;
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
    [self makeSlider];
}

- (IBAction)onPriceChange:(id)sender {
    self.price = [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex];
    
}
- (IBAction)onDistanceChange:(id)sender {
    self.distance = self.distanceCtrl.value;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.delegate passPrice:self didFinishEnteringPrice:self.price];
    [self.delegate passDistance:self didFinishEnteringDistance:self.distance];
    [self.delegate passLongitude:self didFinishEnteringLongitude:self.startLongitude];
    [self.delegate passLatitude:self didFinishEnteringLatitude:self.startLatitude];
    
}

-(void) makeSlider {
    [self.coolSlider setMaxCount:10];
    [self.coolSlider setIndex:10];
    self.coolSlider.labels = @[@"0 miles", @"25 miles", @"50 miles"];
    UIColor* const lightBlue = [[UIColor alloc] initWithRed:21.0f/255 green:180.0f/255  blue:1 alpha:1];//;#15B4FF
    self.coolSlider.sliderCircleColor = lightBlue;
    [self.view addSubview:self.coolSlider];
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
