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
#import "APIManager.h"
#import "SearchFilterViewController.h"

@interface FIndUserViewController ()<SearchFilterViewControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property NSArray *searchedUsers;
@property NSArray *filteredSearchedUsers;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *userSearchBar;
@property APIManager *manager;
@property NSString *price;
@property NSString *searchBy;

@end

@implementation FIndUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    self.userSearchBar.delegate = self;
    self.userSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.manager = [[APIManager alloc] init];
    [self fetchUsers];
}

- (IBAction)didTapFilter:(id)sender {
    [self performSegueWithIdentifier:@"searchFilterSegue" sender:sender];
}

- (void)fetchUsers {
    PFQuery *userQuery = [PFUser query];
    [userQuery includeKey:@"author"];
    userQuery.limit = 20;

    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            // do something with the array of object returned by the call
            self.searchedUsers = users;
            self.filteredSearchedUsers = users;
            [self.usersTableView reloadData];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredSearchedUsers.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    FindUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindUserCell"];
    PFUser *user = self.filteredSearchedUsers[indexPath.row];
    cell.user = user;
    [cell fillCell];
    

    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"%@", self.searchBy);
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedUser, NSDictionary *bindings) {
            return [evaluatedUser[self.searchBy] containsString:searchText];
        }];
        self.filteredSearchedUsers = [self.searchedUsers filteredArrayUsingPredicate:predicate];
        
    }
    else {
        self.filteredSearchedUsers = self.searchedUsers;
    }
    
    [self.usersTableView reloadData];
 
}

#pragma mark - delegate

- (void)passPrice:(SearchFilterViewController *)controller didFinishEnteringPrice:(NSString *)price {
    self.price = price;
}
- (void)passSearch:(SearchFilterViewController *)controller didFinishEnteringSearch:(NSString *)searchBy {
    self.searchBy = searchBy;
}
- (void) refresh {
    [self fetchUsers];
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
    
        
    } else if ([[segue identifier] isEqualToString:@"searchFilterSegue"]) {
        SearchFilterViewController *searchFilterVC = [segue destinationViewController];
        searchFilterVC.delegate = self;
    
        
    }
}


@end
