//
//  FilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import "FilterViewController.h"
#import <math.h>
#import "OBSlider.h"
#import "TagsViewController.h"
#import "TagsCell.h"
#import "SCLAlertView.h"
@import GooglePlaces;

@interface FilterViewController () <TagsViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property (weak, nonatomic) IBOutlet OBSlider *distanceCtrl;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *min;
@property (weak, nonatomic) IBOutlet UILabel *max;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property NSString *price;
@property double distance;
@property double startLatitude;
@property double startLongitude;
@property NSArray *tags;
@property BOOL duplicateTag;

@end

@implementation FilterViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initalTagSetup];
    [self makeButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    if(self.duplicateTag) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"Duplicate Tag" subTitle:@"You have already chosen this tag. Please choose another or continue with what is currently selected." closeButtonTitle:@"Ok" duration:0.0f]; // Warning
    }
}

- (IBAction)onPriceChange:(id)sender {
    self.price = [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex];
    [self.delegate passPrice:self didFinishEnteringPrice:self.price];
    
}
- (IBAction)onDistanceChange:(id)sender {
    NSNumberFormatter *twoDecimalPlacesFormatter = [[NSNumberFormatter alloc] init];
    [twoDecimalPlacesFormatter setMaximumFractionDigits:2];
    [twoDecimalPlacesFormatter setMinimumFractionDigits:0];
    NSString *distanceString = [twoDecimalPlacesFormatter stringFromNumber:[NSNumber numberWithFloat: self.distanceCtrl.value]];
    self.distance = [distanceString doubleValue];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@%@", distanceString, @" miles"];
    [self.delegate passDistance:self didFinishEnteringDistance:self.distance];
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
    self.locationLabel.text = place.formattedAddress;
    [self.delegate passLongitude:self didFinishEnteringLongitude:self.startLongitude];
    [self.delegate passLatitude:self didFinishEnteringLatitude:self.startLatitude];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
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

# pragma mark - tags

- (IBAction)didTapTagBtn:(id)sender {
    [self performSegueWithIdentifier:@"feedFilterTagsSegue" sender:self];
}


- (void)tagsVC:(TagsViewController *)controller didFinishChoosingTag:(Tag *)tag {
    NSMutableArray *temp = [NSMutableArray new];
    self.duplicateTag = NO;
    if (self.tags.count >= 1) {
        for(Tag *oldTag in self.tags) {
            if([oldTag[@"title"] isEqualToString: tag[@"title"]]) {
                self.duplicateTag = YES;
            }
            [temp addObject:oldTag];
        }
    }
    if(!self.duplicateTag) {
        [temp addObject:tag];
    }
    
    self.tags = [temp copy];
    [self.tagsView reloadData];
    [self.delegate passTags:self didFinishEnteringTags:self.tags];
}

- (void)initalTagSetup {
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagsView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.tags[indexPath.row];
    cell.tag = tag;
    cell.hue = [cell.tag.hue doubleValue];
    cell.filter = YES;
    cell.writeYourTag = 0;
    [cell setUp];
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"feedFilterTagsSegue"]) {
        TagsViewController *tagsVC = [segue destinationViewController];
        tagsVC.delegate = self;
        tagsVC.filter = YES;
    }
}


@end
