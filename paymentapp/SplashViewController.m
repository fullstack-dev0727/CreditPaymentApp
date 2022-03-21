//
//  SplashViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "SplashViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MainViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    AppDelegate* appDelegate = APPDELEGATE;
    NSString* username = [appDelegate getUsername];
    NSString* password = [appDelegate getPassword];
    if (username == nil || [username length] == 0) {
        [self performSelector:@selector(turnTab) withObject:self afterDelay:2];
    } else {
        if ([password length] == 0) {
            // facebook login
            [self loginwithFacebook];
        } else {
            // email login
            [PFUser logInWithUsernameInBackground:username password:password
                                            block:^(PFUser *user, NSError *error) {
              
                if (user) {
                    AppDelegate* appDelegate = APPDELEGATE;
                    if ([user[@"account_category"] isEqualToString:@"0"]) {
                        [appDelegate setUserAccounnt:TRUE];
                    } else {
                        [appDelegate setUserAccounnt:FALSE];
                    }
                    [self performSegueWithIdentifier:@"directmain" sender:self];
                } else {
                    // The login failed. Check error to see why.
                    [self messageAlert:@"Failed to login"];
                }
            }];
            
        }
    }

}

- (void)turnTab{
    [self performSegueWithIdentifier:@"guideviewcontroller" sender:self];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"directmain"]) {
        MainViewController* VC = (MainViewController*) segue.destinationViewController;
        AppDelegate* appDelegate = APPDELEGATE;
        if ([appDelegate isUserAccount]) {
            VC.isUser = YES;
        } else {
            VC.isUser = NO;
        }
    }
}

- (void) loginwithFacebook {
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email"] block:^(PFUser* user, NSError* error) {
        if (!user) {
           
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            [self messageAlert:errorMessage];
            return;
            
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection* connection, id result, NSError* error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary* userData = (NSDictionary* )result;
                    NSLog(@"result=%@", result);
                    
                    NSString *facebookID = userData[@"id"];
                    NSString *firstName = userData[@"first_name"];
                    NSString *lastName = userData[@"last_name"];
                    NSString *email = userData[@"email"];
                    AppDelegate* appDelegate = APPDELEGATE;
                    user[@"email"] = email;
                    user[@"fb_id"] = facebookID;
                    user[@"firstname"] = firstName;
                    user[@"lastname"] = lastName;
                    user[@"account_category"] = @"0";
                    user[@"latitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.latitude];
                    user[@"longitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.longitude];
                    
                    NSString *imageUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookID];
                    NSURL *url = [NSURL URLWithString:imageUrlString];
                    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
                    PFFile* imageFile = [PFFile fileWithName:@"photo.png" data: data];
                    
                    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            user[@"photo"] = imageFile;
                            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                               
                                if (!error) {
                                    AppDelegate* appDelegate = APPDELEGATE;
                                    [appDelegate setUserAccounnt:TRUE];
                                    [self performSegueWithIdentifier:@"directmain" sender:self];
                                } else {
                                    [self messageAlert:@"Sign Up Error"];
                                }
                            }];
                        } else {
                           
                        }
                    }];
                    
                } else {
                
                }
            }];
        } else {
          
            NSLog(@"User logged in through Facebook!");
            AppDelegate* appDelegate = APPDELEGATE;
            [appDelegate setUserAccounnt:TRUE];
            [self performSegueWithIdentifier:@"directmain" sender:self];
        }
    }];
    
}

- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}
@end
