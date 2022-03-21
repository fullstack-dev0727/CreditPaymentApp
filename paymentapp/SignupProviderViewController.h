//
//  SignupProviderViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HMPopUpView.h"

@interface SignupProviderViewController : UIViewController <UITextFieldDelegate> {
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UITextField *whereTextField;
    __weak IBOutlet UITextField *typeTextField;
    __weak IBOutlet UITextField *codeTextField;
    __weak IBOutlet UITableView *whereTableView;
    __weak IBOutlet UIScrollView *signupScrollView;
    CGPoint svos;
}

@property (nonatomic, strong) PFUser* user;
@property (nonatomic, retain) UIImage *capturedImage;
@property (nonatomic, strong) NSArray* wherePlacemarks;

- (IBAction)onBackClick:(id)sender;
- (IBAction)onCodeClick:(id)sender;
- (IBAction)onNextClick:(id)sender;
- (IBAction)onWhereTextChanged:(id)sender;
- (void) messageAlert: (NSString*) msg;

@end
