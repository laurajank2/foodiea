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
@interface TagsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *tagsView;
@property APIManager *manager;
@property NSArray *tags;
@property NSMutableArray *colors;
@property NSUInteger colorIndex;

@end

@implementation TagsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.manager = [[APIManager alloc] init];
    self.tagsView.dataSource = self;
    self.tagsView.delegate = self;
    self.colors = [NSMutableArray array];
    self.colorIndex = 0;
    [self colorMaker];
    [self fetchTags];
}

- (void)fetchTags {
    PFQuery *tagQuery = [Tag query];
    [tagQuery orderByAscending:@"title"];
    if(self.filter) {
        [tagQuery whereKey:@"title" notEqualTo:@"zzzzz"];
    }
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
    cell.parentVC = self;
    if ([tag[@"title"] isEqualToString:@"zzzzz"]) {
        cell.tag = tag;
        cell.writeYourTag = 1;
        [cell setUp];
        OutsideTap *outCellTap = [[OutsideTap alloc] initWithTarget:self action:@selector(dismissKeyboard:)];

        outCellTap.avoidCell = cell;
        [self.view addGestureRecognizer:outCellTap];
    } else {
        cell.tag = tag;
        cell.writeYourTag = 0;
        [cell setUp];
    }
    cell.filter = self.filter;
    cell.backgroundColor = [self.colors objectAtIndex:self.colorIndex];
    cell.titleLabel.textColor = ContrastColor([self.colors objectAtIndex:self.colorIndex], YES);
    self.colorIndex++;
    return cell;
}

-(void) dismissKeyboard:(UITapGestureRecognizer *)tapRecognizer {

    OutsideTap *tap = (OutsideTap *)tapRecognizer;

    NSLog(@"cell title : %@", tap.avoidCell.tag[@"title"]);
    [tap.avoidCell.titleLabel resignFirstResponder];

}

- (void)colorMaker {
    float INCREMENT = 0.05;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:0.75
                                    brightness:1.0
                                         alpha:1.0];
        [self.colors addObject:[(UIColor *)color flatten]];
    }
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
