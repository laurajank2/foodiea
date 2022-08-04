//
//  TagsViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import "TagsViewController.h"
#import "TagsCell.h"
#import "Tag.h"
#import "APIManager.h"
#import "OutsideTap.h"
#import <ChameleonFramework/Chameleon.h>
@interface TagsViewController () <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property (weak, nonatomic) IBOutlet UISearchBar *tagsSearch;
@property APIManager *manager;
@property NSArray *tags;
@property NSArray *filteredTags;
@property double lastHue;
@property NSString *searchBy;

@end

@implementation TagsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[APIManager alloc] init];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    self.tagsSearch.delegate = self;
    self.tagsSearch.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self fetchTags];
}

- (void)fetchTags {
    PFQuery *tagQuery = [Tag query];
    [tagQuery orderByAscending:@"hue"];
    if(self.filter) {
        [tagQuery whereKey:@"title" notEqualTo:@"zzzzz"];
    }
    tagQuery.limit = 100;

    void (^callbackForTags)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
            [self tagCallback:tags errorMessage:error];
        };
    [self.manager query:tagQuery getObjects:callbackForTags];
    // fetch data asynchronously
    
}

- (void)tagCallback:(NSArray *)tags errorMessage:(NSError *)error{
    if (tags != nil) {
        // do something with the array of object returned by the call
        self.tags = tags;
        self.filteredTags = self.tags;
        [self.tagsView reloadData];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}



#pragma mark - Collection View

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.filteredTags.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagsView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.filteredTags[indexPath.row];
    cell.parentVC = self;
    if ([tag[@"title"] isEqualToString:@"zzzzz"]) {
        cell.tag = tag;
        cell.writeYourTag = 1;
        if(self.lastHue <0.95){
            cell.hue = self.lastHue + 0.035;
        } else {
            cell.hue = self.tags.count*0.01;
        }
        
        [cell setUp];
        OutsideTap *outCellTap = [[OutsideTap alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        outCellTap.avoidCell = cell;
        [self.view addGestureRecognizer:outCellTap];
    } else {
        cell.tag = tag;
        cell.writeYourTag = 0;
        cell.hue = [cell.tag.hue doubleValue];
        self.lastHue = [cell.tag.hue doubleValue];
        [cell setUp];
    }
    cell.filter = self.filter;
    return cell;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Tag *evaluatedTag, NSDictionary *bindings) {
            return [evaluatedTag[@"title"] localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredTags = [self.tags filteredArrayUsingPredicate:predicate];
        
    }
    else {
        self.filteredTags = self.tags;
    }
    
    [self.tagsView reloadData];
 
}

-(void) dismissKeyboard:(UITapGestureRecognizer *)tapRecognizer {

    OutsideTap *tap = (OutsideTap *)tapRecognizer;

    [tap.avoidCell.titleLabel resignFirstResponder];

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
