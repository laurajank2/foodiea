//
//  TagsCell.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/19/22.
//

#import "TagsCell.h"
#import "SCLAlertView.h"

@implementation TagsCell

@dynamic tag;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.manager = [[APIManager alloc] init];
    self.unique = 1;
    
}

- (void) setUp {
    if(self.writeYourTag == 1) {
        self.titleLabel.text = @"";
        self.spacingLabel.text = @"Write your tag";
        self.titleLabel.userInteractionEnabled = true;
    } else {
        self.titleLabel.text = self.tag[@"title"];
        self.spacingLabel.text = self.tag[@"title"];
        self.titleLabel.userInteractionEnabled = false;
        if(self.parentVC != nil) {
            [self doubleTap];
        }
    }
}

- (void)doubleTap {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.spacingLabel addGestureRecognizer:gestureRecognizer];
    self.spacingLabel.userInteractionEnabled = YES;
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.numberOfTapsRequired = 2;
}

- (IBAction)madeTag:(id)sender {
    [self checkUniqueness];
}


- (void)checkUniqueness{
    PFQuery *tagQuery = [Tag query];
    [tagQuery whereKey:@"title" equalTo:self.titleLabel.text];
    tagQuery.limit = 20;
    void (^callbackForTagCheck)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
        [self callback:tags errorMessage:error];
    };
   [self.manager query:tagQuery getObjects:callbackForTagCheck];
}

- (void)callback:(NSArray *)tags errorMessage:(NSError *)error{
    if (tags != nil) {
        if(!(tags.count == 0)) {
            self.unique = 0;
            SCLAlertView *alert = [[SCLAlertView alloc] init];

            [alert showWarning:self.parentVC title:@"Tag exists" subTitle:@"This tag already exists. Please choose another." closeButtonTitle:@"Ok" duration:0.0f]; // Warning
        } else {
            self.unique = 1;
            [Tag setTitle:self.titleLabel.text
             withCompletion: ^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
                    self.titleLabel.userInteractionEnabled = false;
                    [self doubleTap];
                    
                } else {
                    NSLog(@"Error posting image: %@", error);
                }
            }];
        }
        
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)sendRealTag {
    self.manager = [[APIManager alloc] init];
    __block Tag *finalTag;
    PFQuery *tagQuery = [Tag query];
    [tagQuery whereKey:@"title" equalTo:self.titleLabel.text];
    tagQuery.limit = 40;
    void (^callbackForTagCheck)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
        [self callback:tags finalTag:finalTag errorMessage:error];
    };
    [self.manager query:tagQuery getObjects:callbackForTagCheck];
    NSLog(@"%@", finalTag);
    
}

- (void)callback:(NSArray *)tags finalTag:(Tag *)finalTag errorMessage:(NSError *)error{
    if (tags != nil) {
        for (Tag *arrayTag in tags) {
            finalTag = arrayTag;
        }
        [self.parentVC.delegate tagsVC:self.parentVC didFinishChoosingTag:finalTag];
        [self.parentVC dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"%@", error.localizedDescription);
    }
}


- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer {
    
    [self sendRealTag];
}

@end
