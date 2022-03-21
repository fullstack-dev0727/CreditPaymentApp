//
//  ViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLCImagePickerController.h"
#import <Parse/Parse.h>
#import "SHSPhoneTextField.h"
#import "HMPopUpView.h"

@interface SignViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, DLCImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HMPopUpViewDelegate>{
    __weak IBOutlet UIView *loginView;
    __weak IBOutlet UIScrollView *signupScrollView;
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordField;
    __weak IBOutlet UIImageView *photoImageView;
    __weak IBOutlet UITextField *signupUsernameTextField;
    __weak IBOutlet UITextField *signupFirstnameTextField;
    __weak IBOutlet UITextField *signupLastnameTextField;
    __weak IBOutlet UITextField *signupEmailTextField;
    __weak IBOutlet UITextField *signupPasswordTextField;
    __weak IBOutlet UITextField *signupConfirmPasswordTextField;

    __weak IBOutlet SHSPhoneTextField *phonenumberTextField;
    __weak IBOutlet UIImageView *userCheckImageView;
    __weak IBOutlet UIImageView *providerCheckImageView;
    __weak IBOutlet UISegmentedControl *signSegment;
    int modeValue;
    CGPoint svos;
    UITapGestureRecognizer* tapGesture;
}
@property (nonatomic) BOOL isLogin;
@property (nonatomic, retain) UIImage *capturedImage;
@property (nonatomic, strong) PFUser* user;
- (IBAction)onBackClick:(id)sender;
- (IBAction)onSegmentChanged:(id)sender;
- (IBAction)onForgotPasswordClick:(id)sender;
- (IBAction)onLoginClick:(id)sender;
- (IBAction)onAddPhotoClick:(id)sender;
- (IBAction)onUserClick:(id)sender;
- (IBAction)onProviderClick:(id)sender;
- (IBAction)onNextClick:(id)sender;
- (IBAction)onUserCheckClick:(id)sender;
- (IBAction)onProviderCheckClick:(id)sender;
- (void) messageAlert: (NSString*) msg;
- (void) tapView:(UITapGestureRecognizer*)gesture;
@end

