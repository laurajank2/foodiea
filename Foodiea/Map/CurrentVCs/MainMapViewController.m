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
@property GMSCameraPosition *camera;

@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    [self fetchPosts];
}

-(void)fetchPosts {
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
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
                        BOOL first = YES;
                        for (Post *post in allPosts) {
                            //if so, add them to followed posts
                            if([followedUsers containsObject:post.author.objectId]) {
                                [followedPosts addObject:post];
                                if (first) {
                                    self.camera = [GMSCameraPosition cameraWithLatitude:[post.latitude doubleValue]
                                                                                            longitude:[post.latitude doubleValue]
                                                                                                 zoom:3];
                                    first = NO;
                                }
                            }
                        }
                        self.posts = [followedPosts copy];
                        [self setUpMap];
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
    for(Post *post in self.posts) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([post.latitude doubleValue], [post.longitude doubleValue]);
        marker.title = post.restaurantName;
        marker.snippet =  post.formattedAddress;
        marker.map = self.mapView;
    }
}

-(void)setUpMap{
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:self.camera];
    self.mapView.myLocationEnabled = YES;
    [self.view addSubview:self.mapView];
    [self makeMarkers];
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
