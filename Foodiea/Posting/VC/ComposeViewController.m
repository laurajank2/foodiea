//
//  ComposeViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "ComposeViewController.h"
#import "Post.h"
#import "Tag.h"
#import "TagsCell.h"
#import "APIManager.h"
#import "FontAwesomeKit/FontAwesomeKit.h"
@import GooglePlaces;

@interface ComposeViewController () <TagsViewControllerDelegate ,UICollectionViewDataSource, UICollectionViewDelegate, GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceSegControl;
@property (weak, nonatomic) IBOutlet UITextView *postCaption;
@property (weak, nonatomic) IBOutlet UITextField *restaurantName;
@property (weak, nonatomic) IBOutlet UIDatePicker *postDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property (weak, nonatomic) IBOutlet UIImageView *restaurant;
@property (weak, nonatomic) IBOutlet UIImageView *priceImg;
@property (weak, nonatomic) IBOutlet UIImageView *calImg;
@property (weak, nonatomic) IBOutlet UIImageView *tagImg;
@property (weak, nonatomic) IBOutlet UIImageView *pinImg;
@property GMSPlace *postLocation;
@property APIManager *manager;
@property NSString *userPrice;
@property NSArray *tags;
@property NSMutableArray *colors;
@property NSUInteger colorIndex;
@end

@implementation ComposeViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[APIManager alloc] init];
    [self setIcons];
    [self initalTagSetup];
    [self makeButton];
}


#pragma mark - Icons
-(void) setIcons {
    FAKFontAwesome *restaurantIcon = [FAKFontAwesome spoonIconWithSize:30];
    [restaurantIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    UIImage *restaurantImage = [restaurantIcon imageWithSize:CGSizeMake(30, 30)];
    self.restaurant.image = restaurantImage;
    
    FAKFontAwesome *priceIcon = [FAKFontAwesome dollarIconWithSize:30];
    [priceIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    UIImage *priceImage = [priceIcon imageWithSize:CGSizeMake(30, 30)];
    self.priceImg.image = priceImage;
    
    FAKFontAwesome *calIcon = [FAKFontAwesome calendarIconWithSize:30];
    [calIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    UIImage *calImage = [calIcon imageWithSize:CGSizeMake(30, 30)];
    self.calImg.image = calImage;
    
    FAKFontAwesome *tagIcon = [FAKFontAwesome tagIconWithSize:30];
    [tagIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    UIImage *tagImage = [tagIcon imageWithSize:CGSizeMake(30, 30)];
    self.tagImg.image = tagImage;
    
    FAKFontAwesome *mapIcon = [FAKFontAwesome mapMarkerIconWithSize:30];
    [mapIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    UIImage *mapImage = [mapIcon imageWithSize:CGSizeMake(30, 30)];
    self.pinImg.image = mapImage;
}


#pragma mark - Image
- (IBAction)didTapPhoto:(id)sender {
    [self getImagePicker];
}
- (IBAction)tapLibrary:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)getImagePicker {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1000, 1000, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.postImage.image = originalImage;
    
    // Do something with the images (based on your use case)
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - share

- (IBAction)didTapShare:(id)sender {
    if(![self checkCompletion]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incomplete Information"
                                                                                 message:@"Please fill out all fields before posting."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        CGFloat width = self.postImage.bounds.size.width * 10;
        CGFloat height = self.postImage.bounds.size.height * 10;
        CGSize newSize = CGSizeMake(width, height);
        NSString *selectedPrice = [self.priceSegControl titleForSegmentAtIndex:self.priceSegControl.selectedSegmentIndex];
        [Post postUserImage:[self resizeImage:self.postImage.image withSize:newSize]
            restaurantName: self.restaurantName.text
            restaurantPrice:selectedPrice
            withCaption: self.postCaption.text
            postDate: self.postDatePicker.date
            postLongitude: [NSNumber numberWithFloat:self.postLocation.coordinate.longitude]
            postLatitude: [NSNumber numberWithFloat:self.postLocation.coordinate.latitude]
            postAddress: self.locationLabel.text
            postTags: self.tags
            withCompletion: ^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded) {
                NSLog(@"Successfully posted image!");
                [self setPrice];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                NSLog(@"Error posting image: %@", error);
            }
        }];
    }
    
}

#pragma mark - Price

-(void)setPrice {
    
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    postQuery.limit = 20;

    void (^callbackForPrice)(NSArray *posts, NSError *error) = ^(NSArray *posts, NSError *error){
            [self priceCallback:posts errorMessage:error];
        };
    [self.manager query:postQuery getObjects:callbackForPrice];
   
}

- (void)priceCallback:(NSArray *)posts errorMessage:(NSError *)error{
    NSLog(@"price call back");
    if (posts != nil) {
        int $ = 0;
        int $$ = 0;
        int $$$ = 0;
        int $$$$ = 0;
        for(Post *post in posts) {
            if([post.price isEqualToString:@"$"]) {
                $++;
            }
            if([post.price isEqualToString:@"$$"]) {
                $$++;
            }
            if([post.price isEqualToString:@"$$$"]) {
                $$$++;
            }
            if([post.price isEqualToString:@"$$$$"]) {
                $$$$++;
            }
        }
        
        if($ > $$ && $ > $$$ && $ > $$$$) {
            self.userPrice = @"$";
        } else if($$ > $ && $$ > $$$ && $$ > $$$$) {
            self.userPrice = @"$$";
        } else if($$$ > $ && $$$ > $$ && $$$ > $$$$) {
            self.userPrice = @"$$$";
        } else if ($$$$ > $ && $$$$ > $$ && $$$$ > $$$) {
            self.userPrice = @"$$$$";
        } else {
            self.userPrice = @"$$";
        }
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"price"] = self.userPrice;
        [self.manager saveUserInfo:currentUser];
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

-(BOOL)checkCompletion {
    
    if(self.postImage.image == nil) {
        return NO;
    }
    if([self.restaurantName.text isEqualToString: @""]){
        return NO;
    }
    if([self.postCaption.text isEqualToString: @""]){
        return NO;
    }
    if([self.locationLabel.text isEqualToString: @""]){
        return NO;
    }
    return YES;
}

#pragma mark - Loc Picker

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

// Add a button to the view.
- (void)makeButton{
    [self.btnLaunchAc addTarget:self
               action:NSSelectorFromString(@"autocompleteClicked") forControlEvents:UIControlEventTouchUpInside];
}


// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.locationLabel.text = place.formattedAddress;
    self.postLocation = place;
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

- (IBAction)didTapTagsArrow:(id)sender {
    [self performSegueWithIdentifier:@"composeTagsSegue" sender:self];
}
- (void)tagsVC:(TagsViewController *)controller didFinishChoosingTag:(Tag *)tag {
    NSLog(@"tag");
    NSLog(@"%@", tag);
    NSMutableArray *temp = [NSMutableArray new];
    if (self.tags.count >= 1) {
        for(Tag *oldTag in self.tags) {
            [temp addObject:oldTag];
        }
    }
    [temp addObject:tag];
    NSLog(@"%@", temp);
    self.tags = [temp copy];
    NSLog(@"%@", self.tags);
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
    cell.writeYourTag = 0;
    [cell setUp];
    cell.backgroundColor = [self.colors objectAtIndex:self.colorIndex];
    self.colorIndex++;
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
    if ([[segue identifier] isEqualToString:@"composeTagsSegue"]) {
        TagsViewController *tagsVC = [segue destinationViewController];
        tagsVC.delegate = self;
    }
}


@end
