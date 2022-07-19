//
//  ComposeViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "ComposeViewController.h"
#import "Post.h"
#import "APIManager.h"
@import GooglePlaces;

@interface ComposeViewController () <GMSAutocompleteViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceSegControl;
@property (weak, nonatomic) IBOutlet UITextView *postCaption;
@property (weak, nonatomic) IBOutlet UITextField *restaurantName;
@property (weak, nonatomic) IBOutlet UIDatePicker *postDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property GMSPlace *postLocation;
@property APIManager *manager;
@property NSString *userPrice;
@end

@implementation ComposeViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[APIManager alloc] init];
    [self makeButton];
}
- (IBAction)didTapPhoto:(id)sender {
    [self getImagePicker];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
