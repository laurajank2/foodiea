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
#import "SCLAlertView.h"
#import "APIManager.h"
#import "Tag.h"
#import "TagsCell.h"
#import <ChameleonFramework/Chameleon.h>
#import "FontAwesomeKit/FontAwesomeKit.h"

@interface MainMapViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
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
@property NSMutableArray *following;
@property APIManager *manager;
@property NSMutableArray *currTags;
@property NSMutableArray *markedPosts;
@property NSMutableArray *visMarkedPosts;
@property NSMutableDictionary<NSString*, NSNumber*> *tagCounts;
@property NSMutableDictionary<NSString*, Tag*> *tagDict;


@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [APIManager sharedManager];
    self.tagCounts = [[NSMutableDictionary alloc] init];
    [self setUpTags];
    self.following = [[NSMutableArray alloc] init];
    [self fetchFollowerPosts];
    
}

-(void)setUpTags {
    self.tagCollectionView.dataSource = self;
    self.tagCollectionView.delegate = self;
    self.currTags = [[NSMutableArray alloc] init];
    self.markedPosts = [[NSMutableArray alloc] init];
    self.visMarkedPosts = [[NSMutableArray alloc] init];
    self.tagCounts = [NSMutableDictionary dictionary];
    self.tagDict = [NSMutableDictionary dictionary];
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.currTags.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TagsCell *cell = [self.tagCollectionView dequeueReusableCellWithReuseIdentifier:@"TagsCell" forIndexPath:indexPath];
    Tag *tag = self.currTags[indexPath.row];
    cell.tag = tag;
    cell.writeYourTag = 0;
    cell.hue = [cell.tag.hue doubleValue];
    [cell setUp];
    return cell;
}


-(void)setUpMap{
    self.prevposts = [NSMutableArray new];
    self.camera = [GMSCameraPosition cameraWithLatitude:self.camLatitude longitude:self.camLongitude zoom:5];
    self.prevLatitude = self.visible.nearRight.latitude;
    self.prevLongitude = self.visible.nearRight.longitude;
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:self.camera];
    [self.view addSubview:self.mapView];
    self.visible = [self.mapView.projection visibleRegion];
    [self.view bringSubviewToFront:self.tagCollectionView];
    [self.tagCollectionView setBackgroundView:nil];
    [self.tagCollectionView setBackgroundColor:[UIColor clearColor]];
    [self fetchPosts];
}

-(void)fetchFollowerPosts {
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"following"];
    // generate a query based on that relation
    PFQuery *usersQuery = [relation query];
    void (^callbackForUsers)(NSArray *users, NSError *error) = ^(NSArray *users, NSError *error){
            [self followerCountCallback:users errorMessage:error];
        };
    [self.manager query:usersQuery getObjects:callbackForUsers];
    
}

- (void)followerCountCallback:(NSArray *)users errorMessage:(NSError *)error {
    if (users.count == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showInfo:self title:@"Find Foodies!" subTitle:@"Go to the magnifying glass in the upper left corner to look for foodies to follow for recommendations, ideas, and inspiration." closeButtonTitle:@"Ok!" duration:0.0f];
    } else if(users != nil) {
        for (PFUser *user in users){
            [self.following addObject:user];
        }
        [self firstPostLatLong];
    }
    
}


-(void)firstPostLatLong {
    PFQuery *postQuery = [Post query];
    postQuery.limit = 20;
    __block NSArray *allPosts;
    __block NSSet *followedUsers;
    __block NSMutableArray *followedPosts = [NSMutableArray new];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery whereKey:@"author" containedIn:self.following];
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
                                [self setUpMap];
                                self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                                              target:self
                                                                              selector:@selector(updateMap)
                                                                              userInfo:nil
                                                                              repeats:YES];
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
    [postQuery whereKey:@"author" containedIn:self.following];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            for(Post *post in self.posts) {
                [self.prevposts addObject:post.objectId];
            }
            self.posts = posts;
            [self makeMarkers];
            
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
        [self fetchPostTags:post];
    }
}

-(void)fetchPostTags:(Post * _Nullable)post{
    PFRelation *relation = [post relationForKey:@"tags"];
    // generate a query based on that relation
    PFQuery *usersQuery = [relation query];
    void (^callbackForTags)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
        [self tagsCallback:tags post:post errorMessage:error];
        };
    [self.manager query:usersQuery getObjects:callbackForTags];
    
}

- (void)tagsCallback:(NSArray *)tags post:(Post * _Nullable)post errorMessage:(NSError *)error {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([post.latitude doubleValue], [post.longitude doubleValue]);
    [marker setAppearAnimation:kGMSMarkerAnimationPop];
    marker.title = post.restaurantName;
    marker.snippet =  post.formattedAddress;
    
    if (tags.count >= 1) {
        FAKFontAwesome *mapIcon = [FAKFontAwesome mapMarkerIconWithSize:45];
        if(tags.count > 1) {
            NSMutableArray *tagColors = [[NSMutableArray alloc] init];
            for(Tag *postTag in tags) {
                UIColor *tagColor = [UIColor colorWithHue:[postTag.hue doubleValue]
                                            saturation:0.85 + [postTag.saturation doubleValue]
                                            brightness:0.9 + [postTag.brightness doubleValue]
                                                 alpha:1.0];
                [tagColors addObject:tagColor];
            }
            
            UIColor *gradient = GradientColor(UIGradientStyleLeftToRight, CGRectMake(45,45,45,45), tagColors);
            [mapIcon addAttribute:NSForegroundColorAttributeName value:gradient];
            UIImage *mapPin= [mapIcon imageWithSize:CGSizeMake(45, 45)];
            marker.icon = mapPin;
        } else {
            Tag *tag = [tags objectAtIndex:0];
            UIColor *color = [UIColor colorWithHue:[tag.hue doubleValue]
                                        saturation:0.85 + [tag.saturation doubleValue]
                                        brightness:0.9 + [tag.brightness doubleValue]
                                             alpha:1.0];
            
            [mapIcon addAttribute:NSForegroundColorAttributeName value:color];
            UIImage *mapPin= [mapIcon imageWithSize:CGSizeMake(45, 45)];
            marker.icon = mapPin;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           // do work here to Usually to update the User Interface
            [self.markedPosts addObject:post];
            [self.visMarkedPosts addObject:post];
            [self addTags:tags];
            [self updateCurrTags];
            [self.tagCollectionView reloadData];
        });
        
    } else {
        FAKFontAwesome *mapIcon = [FAKFontAwesome mapMarkerIconWithSize:45];
        [mapIcon addAttribute:NSForegroundColorAttributeName value:[UIColor flatBlackColorDark]];
        UIImage *mapPin= [mapIcon imageWithSize:CGSizeMake(45, 45)];
        marker.icon = mapPin;
    }
    marker.map = self.mapView;
    
}

- (void)updateMap {
    self.visible = [self.mapView.projection visibleRegion];
    if(self.prevLongitude != self.visible.nearRight.longitude || self.prevLatitude != self.visible.nearRight.latitude) {
        [self fetchPosts];
        dispatch_async(dispatch_get_main_queue(), ^{
           // do work here to Usually to update the User Interface
            double minLat = [self findMin:self.visible.nearRight.latitude numTwo:self.visible.farLeft.latitude];
            double maxLat = [self findMax:self.visible.nearRight.latitude numTwo:self.visible.farLeft.latitude];;
            double minLong = [self findMin:self.visible.nearRight.longitude numTwo:self.visible.farLeft.longitude];
            double maxLong = [self findMax:self.visible.nearRight.longitude numTwo:self.visible.farLeft.longitude];
            for(Post *marker in self.markedPosts) {
                //no longer in view
                if([marker.latitude doubleValue] > maxLat || [marker.latitude doubleValue] < minLat || [marker.longitude doubleValue] > maxLong || [marker.longitude doubleValue] < minLong) {
                    if([self.visMarkedPosts containsObject:marker]) {
                        [self.visMarkedPosts removeObject:marker];
                        PFRelation *relation = [marker relationForKey:@"tags"];
                        // generate a query based on that relation
                        PFQuery *usersQuery = [relation query];
                        void (^callbackForTags)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
                            [self markerTagsCallback:tags post:marker removal:YES errorMessage:error];
                            };
                        [self.manager query:usersQuery getObjects:callbackForTags];
                    }
                    
                }
                //returned to view
                if([marker.latitude doubleValue] <= maxLat && [marker.latitude doubleValue] >= minLat && [marker.longitude doubleValue] <= maxLong && [marker.longitude doubleValue] >= minLong) {
                    if(![self.visMarkedPosts containsObject:marker]) {
                        [self.visMarkedPosts addObject:marker];
                        PFRelation *relation = [marker relationForKey:@"tags"];
                        // generate a query based on that relation
                        PFQuery *usersQuery = [relation query];
                        void (^callbackForTags)(NSArray *tags, NSError *error) = ^(NSArray *tags, NSError *error){
                            [self markerTagsCallback:tags post:marker removal:NO errorMessage:error];
                            };
                        [self.manager query:usersQuery getObjects:callbackForTags];
                    }
                }
            }
            
            
            
        });
    }
    self.prevLongitude = self.visible.nearRight.longitude;
    self.prevLatitude = self.visible.nearRight.latitude;
    
    
}

- (void)markerTagsCallback:(NSArray *)tags post:(Post * _Nullable)post removal:(BOOL)removal errorMessage:(NSError *)error {
    if(removal){
        for(Tag *tag in tags) {
            if(self.tagCounts[tag.objectId] != nil) {
                int numTags = [[self.tagCounts valueForKey:tag.objectId] integerValue];
                self.tagCounts[tag.objectId] = [NSNumber numberWithInt:numTags-1];
                
            } else {
                NSLog(@"Error. This tag should be in the array.");
            }
        }
    } else {
        [self addTags:tags];
    }
    [self updateCurrTags];
    [self.tagCollectionView reloadData];
    
}

-(void)addTags:(NSArray * _Nullable)tags {
    for(Tag *tag in tags) {
        if(self.tagCounts[tag.objectId] != nil) {
            int numTags = [[self.tagCounts valueForKey:tag.objectId] integerValue];
            self.tagCounts[tag.objectId] = [NSNumber numberWithInt:numTags+1];
            
        }  else {
            self.tagCounts[tag.objectId] = [NSNumber numberWithInt:1];
            self.tagDict[tag.objectId] = tag;
        }
    }
}

-(void)updateCurrTags {
    self.currTags = [[NSMutableArray alloc] init];
    for(id key in self.tagDict) {
       Tag *tag = [self.tagDict objectForKey:key];
        for(int i = 0; i < [[self.tagCounts valueForKey:tag.objectId] integerValue]; i++) {
            [self.currTags addObject:tag];
        }
    }
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
