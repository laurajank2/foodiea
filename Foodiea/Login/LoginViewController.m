//
//  LoginViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "LoginViewController.h"
#import "HomeFeedViewController.h"
#import <Parse/Parse.h>
#import "SCLAlertView.h"
#import "APIManager.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property APIManager *manager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[APIManager alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}
-(void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
- (IBAction)didTapLogin:(id)sender {
    [self loginUser];
}
- (IBAction)didTapSignUp:(id)sender {
    [self checkUniqueness];
}
- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];

            [alert showWarning:self title:@"Sign Up Failed" subTitle:@"Sign Up failed. Try a new username." closeButtonTitle:@"Ok" duration:0.0f]; // Warning
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            // manually segue to logged in view
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

- (void)checkUniqueness{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:self.usernameField.text];
    userQuery.limit = 2;
    void (^callbackForNameCheck)(NSArray *names, NSError *error) = ^(NSArray *names, NSError *error){
        [self callback:names errorMessage:error];
    };
   [self.manager query:userQuery getObjects:callbackForNameCheck];
}

- (void)callback:(NSArray *)names errorMessage:(NSError *)error{
    if (names != nil) {
        if(!(names.count == 0)) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];

            [alert showWarning:self title:@"Username exists" subTitle:@"This username already exists. Please choose another." closeButtonTitle:@"Ok" duration:0.0f]; // Warning
        } else {
            [self registerUser];
        }
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];

            [alert showWarning:self title:@"Login Failed" subTitle:@"User not recognized in system. Please check your username and password" closeButtonTitle:@"Ok" duration:0.0f]; // Warning
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
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
