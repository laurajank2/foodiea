//
//  FIndUserViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/12/22.
//

#import "FIndUserViewController.h"
#import <Parse/Parse.h>
#import "FindUserCell.h"
#import "ProfileViewController.h"

@interface FIndUserViewController ()<UITableViewDelegate, UITableViewDataSource>

@property NSArray *searchedUsers;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end

@implementation FIndUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    // Do any additional setup after loading the view.
    [self fetchUsers];
}

- (void)fetchUsers {
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"author"];
    userQuery.limit = 20;

    // fetch data asynchronously
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // do something with the array of object returned by the call
            self.searchedUsers = users;
            NSLog(@"the users:");
            NSLog(@"%@", self.searchedUsers);
            [self.usersTableView reloadData];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchedUsers.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    FindUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindUserCell"];
    PFUser *user = self.searchedUsers[indexPath.row];
    cell.user = user;
    [cell fillCell];
    

    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"searchProfileSegue"]) {
        FindUserCell *cell = sender;
        PFUser *userToPass = cell.user;
        UINavigationController *navController = [segue destinationViewController];
        ProfileViewController *profileVC = (ProfileViewController  *)navController.topViewController;
        profileVC.user = userToPass;
    
        
    }
}


@end
