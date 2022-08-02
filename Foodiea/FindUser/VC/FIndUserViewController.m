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
@property NSString *location;
@property NSString *fav;
@property NSArray *tags;

@end

@implementation FIndUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.location = @"";
    self.fav = @"";
    self.price = @"";
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
    if(![self.location isEqualToString: @""]) {
        [userQuery whereKey:@"location" equalTo:self.location];
    }
    if(![self.fav isEqualToString: @""]) {
        [userQuery whereKey:@"fav1" equalTo:self.fav];
    }
    if(![self.price isEqualToString: @""]) {
        [userQuery whereKey:@"price" equalTo:self.price];
    }

    void (^callbackForUse)(NSArray *objects, NSError *error) = ^(NSArray *objects, NSError *error){
            [self callback:objects errorMessage:error];
    };
    [self.manager query:userQuery getObjects:callbackForUse];
}

- (void)callback:(NSArray *)users errorMessage:(NSError *)error{
    if (users != nil) {
        // do something with the array of object returned by the call
        self.searchedUsers = [self shuffle:users];
        self.filteredSearchedUsers = self.searchedUsers;
        [self.usersTableView reloadData];
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (NSArray *) shuffle: (NSArray * _Nullable)array{
    // create temporary autoreleased mutable array
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[array count]];
 
    for (id anObject in array)
    {
        NSUInteger randomPos = arc4random()%([tmpArray count]+1);
        [tmpArray insertObject:anObject atIndex:randomPos];
    }
 
    return [NSArray arrayWithArray:tmpArray];  // non-mutable autoreleased copy
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
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedUser, NSDictionary *bindings) {
            BOOL fitsSearch;
            if (self.searchBy == nil) {
                fitsSearch = [evaluatedUser[@"username"] containsString:searchText];
            } else {
                fitsSearch = [evaluatedUser[self.searchBy] containsString:searchText];
            }
            return fitsSearch;
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
- (void)passFav:(SearchFilterViewController *)controller didFinishEnteringFav:(NSString *)fav {
    self.fav = fav;
}
- (void)passLocation:(SearchFilterViewController *)controller didFinishEnteringLocation:(NSString *)location {
    self.location = location;
}
- (void)passTags:(SearchFilterViewController *)controller didFinishEnteringTags:(NSArray *)tags {
    self.tags = tags;
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
