//
//  AppDelegate.m
//  Foodiea
//
//  Created by Laura Jankowski on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "APIManager.h"
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()
@property APIManager *manager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.manager = [[APIManager alloc] init];
    NSString *appId = [self.manager getAppId];
    NSString *cKey = [self.manager getClientKey];
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = appId;
        configuration.clientKey = cKey;
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    NSString *key = [self.manager getGoogleKey];
    [GMSServices provideAPIKey:key];
    [GMSPlacesClient provideAPIKey:key];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
