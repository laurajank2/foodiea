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

@interface TagsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property APIManager *manager;
@property NSArray *tags;

@end

@implementation TagsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[APIManager alloc] init];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    [self fetchTags];
}

- (void)fetchTags {
    PFQuery *tagQuery = [Tag query];
    [tagQuery orderByAscending:@"title"];
    tagQuery.limit = 20;

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
        [self.tagsView reloadData];
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}



#pragma mark - Collection View

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.tags.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagsView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.tags[indexPath.row];
    //image
    cell.titleLabel.text = tag[@"title"];
    return cell;
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
