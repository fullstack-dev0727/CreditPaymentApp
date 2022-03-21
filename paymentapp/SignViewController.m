//
//  ViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "SignViewController.h"
#import "SignupProviderViewController.h"
#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface SignViewController ()

@end

@implementation SignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    modeValue = 0;
    if (_isLogin) {
        signSegment.selectedSegmentIndex = 0;
        [loginView setHidden:false];
        [signupScrollView setHidden:true];
    } else {
        signSegment.selectedSegmentIndex = 1;
        [loginView setHidden:true];
        [signupScrollView setHidden:false];
    }
    photoImageView.layer.cornerRadius = photoImageView.frame.size.height / 2;
    photoImageView.layer.masksToBounds = YES;
    photoImageView.layer.borderWidth = 0;
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
    
    [phonenumberTextField.formatter setDefaultOutputPattern:@"### - ### - ####"];
}
- (void) tapView:(UITapGestureRecognizer*)gesture {
    if ( tapGesture ) {
        [usernameTextField resignFirstResponder];
        [passwordField resignFirstResponder];
        [signupUsernameTextField resignFirstResponder];
        [signupPasswordTextField resignFirstResponder];
        [signupConfirmPasswordTextField resignFirstResponder];
        [signupEmailTextField resignFirstResponder];
        [signupFirstnameTextField resignFirstResponder];
        [signupLastnameTextField resignFirstResponder];
        [phonenumberTextField resignFirstResponder];
        [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    }
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
    if ([segue.identifier isEqualToString:@"signtomain"]) {
        MainViewController* VC = (MainViewController*) segue.destinationViewController;
        AppDelegate* appDelegate = APPDELEGATE;
        if ([appDelegate isUserAccount]) {
            VC.isUser = YES;
        } else {
            VC.isUser = NO;
        }
    } else if ([segue.identifier isEqualToString:@"signupproviderviewcontroller"]) {
        SignupProviderViewController* signupProviderVC = (SignupProviderViewController*) segue.destinationViewController;
        signupProviderVC.user = _user;
        signupProviderVC.capturedImage = _capturedImage;
    }
}
- (IBAction)onBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSegmentChanged:(id)sender {
    if (signSegment.selectedSegmentIndex == 0) {
        [loginView setHidden:false];
        [signupScrollView setHidden:true];
    } else {
        [loginView setHidden:true];
        [signupScrollView setHidden:false];
        
    }
}
- (void) forgotFunc {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:@"To retrieve your password, please enter your email address" okButtonTitle:@"Ok" cancelButtonTitle:@"Cancel" delegate:self];
    hmPopUp.tag = 1;
    [hmPopUp showInView:self.view];
}
- (IBAction)onForgotPasswordClick:(id)sender {
    [self forgotFunc];
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 800)];
    svos = signupScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:signupScrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [signupScrollView setContentOffset:pt animated:YES];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == usernameTextField) {
        [passwordField becomeFirstResponder];
        return YES;
    } else if (textField == passwordField) {
        [textField resignFirstResponder];
        [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
        return YES;
    }
    if (textField == signupUsernameTextField) {
        [signupFirstnameTextField becomeFirstResponder];
        return YES;
    } else if (textField == signupFirstnameTextField) {
        [signupLastnameTextField becomeFirstResponder];
        return YES;
    } else if (textField == signupLastnameTextField) {
        [signupEmailTextField becomeFirstResponder];
        return YES;
    } else if (textField == signupEmailTextField) {
        [signupPasswordTextField becomeFirstResponder];
        return YES;
    } else if (textField == signupPasswordTextField) {
        [signupConfirmPasswordTextField becomeFirstResponder];
        return YES;
    } else if (textField == signupConfirmPasswordTextField) {
        [phonenumberTextField becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    return YES;
}
- (IBAction)onLoginClick:(id)sender {
    if ([usernameTextField.text length] == 0) {
        [self messageAlert:@"Your Username cannot be empty."];
        return;
    }
    if ([passwordField.text length] == 0) {
        [self messageAlert:@"Your Password cannot be empty."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PFUser logInWithUsernameInBackground:[usernameTextField.text lowercaseString] password:passwordField.text
                                    block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (user) {
            AppDelegate* appDelegate = APPDELEGATE;
            if ([user[@"account_category"] isEqualToString:@"0"]) {
                [appDelegate setUserAccounnt:TRUE];
            } else {
                [appDelegate setUserAccounnt:FALSE];
            }
            [appDelegate setUsername:user.username];
            [appDelegate setPassword:passwordField.text];
            [self performSegueWithIdentifier:@"signtomain" sender:self];
        } else {
            // The login failed. Check error to see why.
            //NSString *errorString = [error userInfo][@"error"];
           
            HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:@"Login attempt failed, please try again" cancelButtonTitle:@"Ok" delegate:self];
            hmPopUp.tag = 2;
            [hmPopUp showInView:self.view];
        }
    }];
    
}

- (IBAction)onAddPhotoClick:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Album", nil];
    
    UIWindow* window = [[UIApplication sharedApplication] keyWindow];
    if ([window.subviews containsObject:self.view]) {
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        [sheet showInView:window];
    }
}

- (IBAction)onUserClick:(id)sender {
    modeValue = 0;
    [userCheckImageView setImage:[UIImage imageNamed:@"icon_check_selected.png"]];
    [providerCheckImageView setImage:[UIImage imageNamed:@"icon_check_unselected.png"]];
}

- (IBAction)onProviderClick:(id)sender {
    modeValue = 1;
    [userCheckImageView setImage:[UIImage imageNamed:@"icon_check_unselected.png"]];
    [providerCheckImageView setImage:[UIImage imageNamed:@"icon_check_selected.png"]];
}

- (IBAction)onNextClick:(id)sender {
    if (_capturedImage == nil) {
        [self messageAlert:@"Please upload a selfie"];
        return;
    }
    if ([signupUsernameTextField.text length] == 0) {
        [self messageAlert:@"Your Username cannot be empty."];
        return;
    }
    if ([signupFirstnameTextField.text length] == 0) {
        [self messageAlert:@"Your First Name cannot be empty."];
        return;
    }
    if ([signupLastnameTextField.text length] == 0) {
        [self messageAlert:@"Your Last Name cannot be empty."];
        return;
    }
    if ([signupEmailTextField.text length] == 0) {
        [self messageAlert:@"Your Email cannot be empty."];
        return;
    }
    if ([signupPasswordTextField.text length] == 0) {
        [self messageAlert:@"Your Password cannot be empty."];
        return;
    }
    if (![signupPasswordTextField.text isEqualToString:signupConfirmPasswordTextField.text]) {
        [self messageAlert:@"Your Password and Re-type Password is not matched."];
        return;
    }
    if ([phonenumberTextField.text length] == 0) {
        [self messageAlert:@"Your Phone Number cannot be empty."];
        return;
    }

    NSString* phoneNumber = [[phonenumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    AppDelegate* appDelegate = APPDELEGATE;
    _user = [PFUser user];
    _user.username = [signupUsernameTextField.text lowercaseString];
    _user.password = signupPasswordTextField.text;
    _user.email = signupEmailTextField.text;
    _user[@"firstname"] = signupFirstnameTextField.text;
    _user[@"lastname"] = signupLastnameTextField.text;
    _user[@"phone"] = phoneNumber;
    _user[@"latitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.latitude];
    _user[@"longitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.longitude];
    if (modeValue == 1) {
         _user[@"account_category"] = @"1";
        [self performSegueWithIdentifier:@"signupproviderviewcontroller" sender:self];
    } else {
        _user[@"account_category"] = @"0";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        PFQuery* query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"phone" equalTo:phoneNumber];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] == 0) {
                PFQuery* query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"email" equalTo:signupEmailTextField.text];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects count] == 0) {
                        NSData *imageData = UIImagePNGRepresentation(_capturedImage);
                        PFFile *imageFile = [PFFile fileWithName:@"photo.png" data:imageData];
                        
                        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                _user[@"photo"] = imageFile;
                                
                                [_user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (!error) {
                                        // Hooerror	NSError *	domain: @"Parse" - code: 202	0x17a5ef00ray! Let them use the app now.
                                        
                                        [appDelegate setUserAccounnt:TRUE];
                                        [self performSegueWithIdentifier:@"signtomain" sender:self];
                                    } else {
                                        NSString *errorString = [error userInfo][@"error"];
                                        // Show the errorString somewhere and let the user try again.
                                        [self messageAlert: [NSString stringWithFormat:@"Failed to signup. %@", errorString]];
                                    }
                                }];
                            } else {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                            }
                        }];
                        
                    } else {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self messageAlert:@"Failed to signup. email already taken"];
                    }
                }];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self messageAlert:@"Failed to signup. phone number already taken"];
            }
        }];
        
    }
   
    
}

- (IBAction)onUserCheckClick:(id)sender {
    modeValue = 0;
    [userCheckImageView setImage:[UIImage imageNamed:@"icon_check_selected.png"]];
    [providerCheckImageView setImage:[UIImage imageNamed:@"icon_check_unselected.png"]];

}

- (IBAction)onProviderCheckClick:(id)sender {
    modeValue = 1;
    [userCheckImageView setImage:[UIImage imageNamed:@"icon_check_unselected.png"]];
    [providerCheckImageView setImage:[UIImage imageNamed:@"icon_check_selected.png"]];
}
- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:self];
    hmPopUp.tag = 0;
    [hmPopUp showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
            break;
        case 1:
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing = YES;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
            picker = nil;
        }
            break;
        case 2:
            return;
            break;
        default:
            break;
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"didFinishPickingImage");
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"didFinishPickingMediaWithInfo");
    if ([picker isKindOfClass:[DLCImagePickerController class]]) {
        _capturedImage = [info objectForKey:@"image"];
    }else{
        _capturedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [photoImageView setImage:_capturedImage];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }];
}

#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if (alertView.tag == 1) { // forgot dialog
        if (!accept) {
            return;
        }
        if ([text length] == 0) {
            [self messageAlert: @"Please input email address"];
            return;
        }
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [PFUser requestPasswordResetForEmailInBackground:text block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self messageAlert: @"success"];
            } else {
                HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitleWithoutTextField:@"Please choose another email address" okButtonTitle:@"Sign Up" cancelButtonTitle:@"Try Again" delegate:self];
                hmPopUp.tag = 3;
                [hmPopUp showInView:self.view];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    } else if (alertView.tag == 2) { // login failed
        [usernameTextField setText:@""];
        [passwordField setText:@""];
        [usernameTextField becomeFirstResponder];
    } else if (alertView.tag == 3) { // forgot failed
        if (!accept) {
            [self forgotFunc];
            return;
        }
        signSegment.selectedSegmentIndex = 1;
        [loginView setHidden:true];
        [signupScrollView setHidden:false];
    }
}


@end
