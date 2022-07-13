//
//  FilterViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/13/22.
//

#import "FilterViewController.h"

@interface FilterViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceCtrl;
@property (weak, nonatomic) IBOutlet UISlider *distanceCtrl;
@property NSString *price;
@property NSString *distance;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onPriceChange:(id)sender {
    self.price = [self.priceCtrl titleForSegmentAtIndex:self.priceCtrl.selectedSegmentIndex];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    NSString *itemToPassBack = self.price;
    [self.delegate addItemViewController:self didFinishEnteringItem:itemToPassBack];
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
