//
//  GuideViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "GuideViewController.h"
#import "SignViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "FSNConnection.h"
@interface GuideViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) ACAccountStore *accountStore;

@property (nonatomic, strong) ACAccount *facebookAccount;
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (int i=0;i<3;i++) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"guide_background%d.png", i+1]]];
        imageView.frame =  CGRectMake(i * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        [guideScrollView addSubview:imageView];
    }

    guideScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, guideScrollView.contentSize.height);

}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"signviewcontroller"]) {
        SignViewController* VC = (SignViewController*) segue.destinationViewController;
        VC.isLogin = isClickedLogin;
    } else if ([segue.identifier isEqualToString:@"guidetomain"]) {
        MainViewController* VC = (MainViewController*) segue.destinationViewController;
        VC.isUser = YES;
    }

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    pageControl.currentPage = page;
    switch (page) {
        case 0: {
            [guideTextView setText:@"Guide Line Screen1"];
        }
            break;
        case 1: {
            [guideTextView setText:@"Guide Line Screen2"];
        }
            break;
        case 2: {
            [guideTextView setText:@"Guide Line Screen3"];
        }
            break;
    }
}


- (IBAction)onLoginClick:(id)sender {
    isClickedLogin = TRUE;
    [self performSegueWithIdentifier:@"signviewcontroller" sender:self];
}

- (IBAction)onSignupClick:(id)sender {
    isClickedLogin = FALSE;
    [self performSegueWithIdentifier:@"signviewcontroller" sender:self];
}
- (void) loginwithFacebook {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email"] block:^(PFUser* user, NSError* error) {
        if (!user) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                if (!error) {
                                    AppDelegate* appDelegate = APPDELEGATE;
                                    [appDelegate setUserAccounnt:TRUE];
                                    [appDelegate setUsername:user.username];
                                    [appDelegate setPassword:@""];
                                    [self performSegueWithIdentifier:@"guidetomain" sender:self];
                                } else {
                                    [self messageAlert:@"Sign Up Error"];
                                    
                                }
                            }];
                        } else {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    }];
                    
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"User logged in through Facebook!");
            AppDelegate* appDelegate = APPDELEGATE;
            [appDelegate setUserAccounnt:TRUE];
            [appDelegate setUsername:user.username];
            [appDelegate setPassword:@""];
            [self performSegueWithIdentifier:@"guidetomain" sender:self];
        }
    }];

}
- (IBAction)onFacebookClick:(id)sender {
    [self loginwithFacebook];
}
- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}
@end
