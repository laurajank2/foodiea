//
//  MainMapViewController.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/15/22.
//

#import "MainMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "Post.h"

@interface MainMapViewController ()
@property GMSMapView *mapView;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *prevposts;
@property GMSCameraPosition *camera;
@property GMSVisibleRegion visible;
@property NSTimer *timer;
@property double camLongitude;
@property double camLatitude;
@property double prevLongitude;
@property double prevLatitude;

@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self firstPostLatLong];
    [self setUpMap];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                  target:self
                                                  selector:@selector(updateMap)
                                                  userInfo:nil
                                                  repeats:YES];
}

-(void)setUpMap{
    self.prevposts = [NSMutableArray new];
    self.camera = [GMSCameraPosition cameraWithLatitude:self.camLatitude longitude:self.camLongitude zoom:5];
    self.prevLatitude = self.visible.nearRight.latitude;
    self.prevLongitude = self.visible.nearRight.longitude;
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:self.camera];
    [self.view addSubview:self.mapView];
    self.visible = [self.mapView.projection visibleRegion];
    [self fetchPosts];
}

-(void)firstPostLatLong {
    PFQuery *postQuery = [Post query];
    postQuery.limit = 20;
    __block NSArray *allPosts;
    __block NSSet *followedUsers;
    __block NSMutableArray *followedPosts = [NSMutableArray new];
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
                // all posts in descending order
                allPosts = posts;
                PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
                // generate a query based on that relation
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                    if (users != nil) {
                        // get users and make a mutable array of ids
                        NSMutableArray *userIds = [NSMutableArray new];
                        for (PFUser *user in users){
                            [userIds addObject:user.objectId];
                        }
                        //make a set of the userids
                        followedUsers = [NSSet setWithArray:[userIds copy]];
                        //check if posts have an author you follow
                        for (Post *post in allPosts) {
                            //if so, add them to followed posts
                            if([followedUsers containsObject:post.author.objectId]) {
                                [followedPosts addObject:post];
                                self.camLatitude = [post.latitude doubleValue];
                                self.camLongitude = [post.longitude doubleValue];
                                break;
                            }
                        }
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void)fetchPosts {
    double minLat = [self findMin:self.visible.nearRight.latitude numTwo:self.visible.farLeft.latitude];
    double maxLat = [self findMax:self.visible.nearRight.latitude numTwo:self.visible.farLeft.latitude];;
    double minLong = [self findMin:self.visible.nearRight.longitude numTwo:self.visible.farLeft.longitude];
    double maxLong = [self findMax:self.visible.nearRight.longitude numTwo:self.visible.farLeft.longitude];
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery whereKey:@"latitude" greaterThan:[NSNumber numberWithDouble:minLat]];
    [postQuery whereKey:@"latitude" lessThan:[NSNumber numberWithDouble:maxLat]];
    [postQuery whereKey:@"longitude" greaterThan:[NSNumber numberWithDouble:minLong]];
    [postQuery whereKey:@"longitude" lessThan:[NSNumber numberWithDouble:maxLong]];
    [postQuery whereKey:@"objectId" notContainedIn:self.prevposts];
    postQuery.limit = 20;
    __block NSArray *allPosts;
    __block NSSet *followedUsers;
    __block NSMutableArray *followedPosts = [NSMutableArray new];

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
                // all posts in descending order
                allPosts = posts;
                PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
                // generate a query based on that relation
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                    if (users != nil) {
                        // get users and make a mutable array of ids
                        NSMutableArray *userIds = [NSMutableArray new];
                        for (PFUser *user in users){
                            [userIds addObject:user.objectId];
                        }
                        //make a set of the userids
                        followedUsers = [NSSet setWithArray:[userIds copy]];
                        //check if posts have an author you follow
                        for (Post *post in allPosts) {
                            //if so, add them to followed posts
                            if([followedUsers containsObject:post.author.objectId]) {
                                [followedPosts addObject:post];
                            }
                        }
                        for(Post *post in self.posts) {
                            [self.prevposts addObject:post.objectId];
                        }
                        self.posts = [followedPosts copy];
                        [self makeMarkers];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
   
}

-(void)makeMarkers {
    NSMutableArray *onlyCurr = [NSMutableArray new];
    for(Post *post in self.posts) {
        if(![self.prevposts containsObject:post.objectId]) {
            [onlyCurr addObject:post];
        }
    }
    for(Post *post in onlyCurr) {
        NSLog(@"%@", post.restaurantName);
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([post.latitude doubleValue], [post.longitude doubleValue]);
        [marker setAppearAnimation:kGMSMarkerAnimationPop];
        marker.title = post.restaurantName;
        marker.snippet =  post.formattedAddress;
        marker.map = self.mapView;
    }
}

- (void)updateMap {
    self.visible = [self.mapView.projection visibleRegion];
    if(self.prevLongitude != self.visible.nearRight.longitude || self.prevLatitude != self.visible.nearRight.latitude) {
        [self fetchPosts];
    }
    self.prevLongitude = self.visible.nearRight.longitude;
    self.prevLatitude = self.visible.nearRight.latitude;
    
}

-(double)findMin:(double)numOne numTwo:(double) numTwo {
    if(numOne <= numTwo) {
        return numOne;
    } else {
        return numTwo;
    }
}

-(double)findMax:(double)numOne numTwo:(double) numTwo {
    if(numOne >= numTwo) {
        return numOne;
    } else {
        return numTwo;
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
