//
//  SearchFilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/18/22.
//

#import "SearchFilterViewController.h"
#import "TagsCell.h"
@import GooglePlaces;

@interface SearchFilterViewController () <TagsViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *favField;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property NSString *price;
@property NSString *searchBy;

@property NSArray *tags;
@property NSMutableArray *colors;
@property NSUInteger colorIndex;
@property BOOL duplicateTag;

@end

@implementation SearchFilterViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeButton];
    [self initalTagSetup];
    self.locationLabel.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.delegate passSearch:self didFinishEnteringSearch:[self.searchCtrl titleForSegmentAtIndex:self.searchCtrl.selectedSegmentIndex]];
    NSLog(@"%@", self.favField.text);
    [self.delegate passFav:self didFinishEnteringFav:self.favField.text];
    [self.delegate passLocation:self didFinishEnteringLocation:self.locationLabel.text];
    NSLog(@"filter price");
    NSLog(@"%@", [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex]);
    [self.delegate passPrice:self didFinishEnteringPrice:[self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex]];
    [self.delegate refresh];
    NSLog(@"%@", self.searchBy);
}

#pragma mark - Location autocomplete

// Add a button to the view.
- (void)makeButton{
    [self.locationBtn addTarget:self
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
    self.locationLabel.text = place.name;
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

#pragma mark - Tags

- (IBAction)didTapTagArrow:(id)sender {
    [self performSegueWithIdentifier:@"userFilterTagsSegue" sender:sender];
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
}

- (void)initalTagSetup {
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    self.colors = [NSMutableArray array];
    self.colorIndex = 0;
    [self colorMaker];
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagsView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.tags[indexPath.row];
    cell.tag = tag;
    cell.filter = YES;
    cell.writeYourTag = 0;
    [cell setUp];
//    cell.backgroundColor = [self.colors objectAtIndex:self.colorIndex];
//    self.colorIndex++;
    return cell;
}

- (void)colorMaker {
    float INCREMENT = 0.05;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:0.75
                                    brightness:1.0
                                         alpha:1.0];
        [self.colors addObject:color];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"userFilterTagsSegue"]) {
        TagsViewController *tagsVC = [segue destinationViewController];
        tagsVC.delegate = self;
        tagsVC.filter = YES;
    }
}


@end
