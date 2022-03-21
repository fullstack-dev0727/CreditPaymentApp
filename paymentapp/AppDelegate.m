//
//  AppDelegate.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if (IS_IOS8) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [_locationManager startUpdatingLocation];

    [Parse setApplicationId:@"wyVccN6MwMaSMIw39mtn2Rlv3QVR0G0DcTrxERoX" clientKey:@"PzPJ0qoaRJdesqU1gxGUmcOZlu3Whsh7e8JLZKUh"];
    [PFFacebookUtils initializeFacebook];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager*) manager didFailWithError:(NSError *)error {
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    _currentLocation = location;
    NSLog(@"dodUpdateToLocation: %f %f", location.coordinate.latitude, location.coordinate.longitude);
    PFUser* currentUser = [PFUser currentUser];
    if (currentUser != nil) {
        currentUser[@"latitude"] = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        currentUser[@"longitude"] = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
           
        }];
    }
}
- (BOOL) isUserAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [defaults boolForKey:@"account"];
    return flag;
}
- (void) setUserAccounnt:(BOOL)flag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:flag forKey:@"account"];
    [defaults synchronize];
}
- (NSString*) getUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* name = [defaults stringForKey:@"username"];
    return name;
}
- (void) setUsername:(NSString*) name {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"username"];
    [defaults synchronize];
}
- (NSString*) getPaymentInfo: (NSString*) key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* name = [defaults stringForKey:key];
    return name;
}
- (void) setPaymentInfo:(NSString*) key value : (NSString*) value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}
- (NSString*) getPassword {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* pw = [defaults stringForKey:@"password"];
    return pw;
}
- (void) setPassword:(NSString*) pw {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pw forKey:@"password"];
    [defaults synchronize];
}
@end
