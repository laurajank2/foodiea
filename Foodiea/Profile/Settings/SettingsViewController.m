//
//  SettingsViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "APIManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SCLAlertView.h"
@import GooglePlaces;

@interface SettingsViewController () <UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *screenName;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextView *bio;
@property (weak, nonatomic) IBOutlet UITextField *fav1;
@property (weak, nonatomic) IBOutlet UITextField *fav2;
@property (weak, nonatomic) IBOutlet UITextField *fav3;
@property (weak, nonatomic) IBOutlet UITextField *fav1Link;
@property (weak, nonatomic) IBOutlet UITextField *fav2Link;
@property (weak, nonatomic) IBOutlet UITextField *fav3Link;
@property (weak, nonatomic) IBOutlet UIButton *btnLaunchAc;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) PFUser *user;
@property APIManager *manager;
@property GMSPlace *postLocation;
@end

@implementation SettingsViewController {
    GMSAutocompleteFilter *_filter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bio.delegate = self;
    self.screenName.delegate = self;
    self.userName.delegate = self;
    self.fav1.delegate = self;
    self.fav2.delegate = self;
    self.fav3.delegate = self;
    self.user = [PFUser currentUser];
    self.profileImage.file = self.user[@"profileImage"];
    [self.profileImage loadInBackground];
    self.manager = [[APIManager alloc] init];
    [self filloutUser];
    [self makeButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self viewDidEndEditing];
    [self fieldDidEndEditing];
}

-(void)dismissKeyboard {
    [self.userName resignFirstResponder];
    [self.screenName resignFirstResponder];
    [self.bio resignFirstResponder];
    [self.fav1 resignFirstResponder];
    [self.fav2 resignFirstResponder];
    [self.fav3 resignFirstResponder];
    [self.fav1Link resignFirstResponder];
    [self.fav2Link resignFirstResponder];
    [self.fav3Link resignFirstResponder];
}

-(void)filloutUser {
    //image
    self.profileImage.file = self.user[@"profileImage"];
    [self.profileImage loadInBackground];
    [self.profileImage.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [self.profileImage.layer setBorderWidth: 1.5];
    self.userName.text = self.user.username;
    self.screenName.text = self.user[@"screenname"];
    self.bio.text = self.user[@"bio"];
    self.fav1.text = self.user[@"fav1"];
    self.fav2.text = self.user[@"fav2"];
    self.fav3.text = self.user[@"fav3"];
    self.fav1Link.text = self.user[@"fav1Link"];
    self.fav2Link.text = self.user[@"fav2Link"];
    self.fav3Link.text = self.user[@"fav3Link"];
    
}

- (IBAction)logout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        LoginViewController *loginViewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        sceneDelegate.window.rootViewController = loginViewcontroller;
    }];
    
}

- (void)viewDidEndEditing {
    self.user[@"bio"] = self.bio.text;
    [self.manager saveUserInfo:self.user];
}

- (void)fieldDidEndEditing {
    self.user[@"username"] = self.userName.text;
    self.user[@"screenname"] = self.screenName.text;
    self.user[@"fav1"] = self.fav1.text;
    self.user[@"fav2"] = self.fav2.text;
    self.user[@"fav3"] = self.fav3.text;
    self.user[@"fav1Link"] = self.fav1Link.text;
    self.user[@"fav2Link"] = self.fav2Link.text;
    self.user[@"fav3Link"] = self.fav3Link.text;
    [self.manager saveUserInfo:self.user];
}
- (IBAction)changePhoto:(id)sender {
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
    self.profileImage.image = originalImage;
    CGFloat width = self.profileImage.bounds.size.width * 10;
    CGFloat height = self.profileImage.bounds.size.height * 10;
    CGSize newSize = CGSizeMake(width, height);
    PFFileObject *imgFile = [self.manager getPFFileFromImage:[self resizeImage:self.profileImage.image withSize:newSize]];
    self.user[@"profileImage"] = imgFile;
    [self.manager saveUserInfo:self.user];

    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.locationLabel.text = place.name;
    self.user[@"location"] = place.name;
    self.user[@"expertiseLat"] = [NSNumber numberWithDouble:place.coordinate.latitude];
    self.user[@"expertiseLong"] = [NSNumber numberWithDouble:place.coordinate.longitude];
    [self.manager saveUserInfo:self.user];
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

@end
