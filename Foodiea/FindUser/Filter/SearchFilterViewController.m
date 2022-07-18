//
//  SearchFilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/18/22.
//

#import "SearchFilterViewController.h"

@interface SearchFilterViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property NSString *price;
@property NSString *searchBy;

@end

@implementation SearchFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.delegate passSearch:self didFinishEnteringSearch:self.searchBy];
    NSLog(@"%@", self.searchBy);
}

- (IBAction)onPriceChange:(id)sender {
    self.price = [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex];
}
- (IBAction)onSearchChange:(id)sender {
    self.searchBy = [self.searchCtrl titleForSegmentAtIndex:self.searchCtrl.selectedSegmentIndex];
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
