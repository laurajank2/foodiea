//
//  ComposeViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/6/22.
//

#import "ComposeViewController.h"
#import "Post.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceSegControl;
@property (weak, nonatomic) IBOutlet UITextView *postCaption;
@property (weak, nonatomic) IBOutlet UITextField *restaurantName;
@property (weak, nonatomic) IBOutlet UIDatePicker *postDatePicker;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    CGFloat width = self.postImage.bounds.size.width * 10;
    CGFloat height = self.postImage.bounds.size.height * 10;
    CGSize newSize = CGSizeMake(width, height);
    NSString *selectedPrice = [self.priceSegControl titleForSegmentAtIndex:self.priceSegControl.selectedSegmentIndex];
    [Post postUserImage:[self resizeImage:self.postImage.image withSize:newSize]
        restaurantName: self.restaurantName.text
        restaurantPrice:selectedPrice
        withCaption: self.postCaption.text
        postDate: self.postDatePicker.date
        withCompletion: ^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            NSLog(@"Successfully posted image!");
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            NSLog(@"Error posting image: %@", error);
        }
    }];
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
