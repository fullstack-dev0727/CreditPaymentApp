//
//  GuideViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "HMPopUpView.h"

@interface GuideViewController : UIViewController {
    __weak IBOutlet UIScrollView *guideScrollView;
    __weak IBOutlet UIPageControl *pageControl;
    __weak IBOutlet UILabel *guideTextView;
    __weak IBOutlet UIButton *loginButton;
    __weak IBOutlet UIButton *signupButton;
    __weak IBOutlet UIButton *facebookButton;
    BOOL isClickedLogin;
}
- (IBAction)onLoginClick:(id)sender;
- (IBAction)onSignupClick:(id)sender;
- (IBAction)onFacebookClick:(id)sender;
- (void) loginwithFacebook;

@end
