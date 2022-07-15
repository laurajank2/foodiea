//
//  ProfileCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/7/22.
//

#import "ProfileCell.h"

@implementation ProfileCell
- (IBAction)getUserFeed:(id)sender {
    [self.profileVC performSegueWithIdentifier:@"profileHomeSegue" sender:sender];
}

@end
