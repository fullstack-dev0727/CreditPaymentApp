//
//  InviteUserViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "InviteUserViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FSNConnection.h"
#import <Parse/Parse.h>

@interface InviteUserViewController ()
@property (nonatomic) FSNConnection *connection;
@end

@implementation InviteUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [phoneTextField.formatter setDefaultOutputPattern:@"### - ### - ####"];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) tapView:(UITapGestureRecognizer*)gesture {
    if ( tapGesture ) {
        [phoneTextField resignFirstResponder];
        [emailTextField resignFirstResponder];
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

- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}

- (IBAction)onSendInviteClick:(id)sender {
    PFUser* currentUser = [PFUser currentUser];
    NSString* username = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
    if ([emailTextField.text length] > 0) {
        inviteMessage = [NSString stringWithFormat:@"%@ has invited you to the application. %@", username, @"https://play.google.com/store/apps/details?id=com.alsight.main"];
        [self sendInviteWithEmail];
        return;
    } else if ([phoneTextField.text length] > 0){
        [self sendInviteWithSMS];
        return;
    }
    [self messageAlert:@"Please enter email address or phone number"];
    
}
- (void) sendInviteWithEmail {
    [self.connection cancel];
    self.connection = [self emailConnection];
    [self.connection start];
}
#pragma mark - FSConnection Functions
- (FSNConnection *)emailConnection {
    PFUser* currentUser = [PFUser currentUser];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SERVER_INVITE_URL]];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     emailTextField.text,   @"to_email",
     currentUser.email,     @"from_email",
     inviteMessage, @"msg",
     nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSLog(@"%@",[NSString stringWithUTF8String:[c.responseData bytes]]);
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSDictionary *result = (NSDictionary*)c.parseResult;
                      NSLog(@"%@", result);
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                      NSString* status = result[@"status"];
                      if (status != nil && [status isEqualToString:@"success"]) {
                          [self messageAlert:@"Successfully invited tipper"];
                      } else{
                          [self messageAlert:@"Failed to invited tipper"];
                      }
                      if ([phoneTextField.text length] > 0) {
                          [self sendInviteWithSMS];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}
- (void) sendInviteWithSMS {
    [self.connection cancel];
    self.connection = [self smsConnection];
    [self.connection start];
}
#pragma mark - FSConnection Functions
- (FSNConnection *)smsConnection {
    NSString* phoneNumber = [[phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    PFUser* currentUser = [PFUser currentUser];
    NSString* msg = [NSString stringWithFormat:@"%@ %@ has invited you to the application.\n%@\n%@", currentUser[@"firstname"], currentUser[@"lastname"], IOS_APP_LINK, ANDROID_APP_LINK];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:SERVER_SMS_URL,TWILIO_ACCOUNT_SID]];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     TWILIO_PHONENUMBER,   @"From",
     phoneNumber,     @"To",
     msg, @"Body",
     nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString* userpass = [NSString stringWithFormat:@"%@:%@", TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN];
    
    NSData *nsdata = [userpass dataUsingEncoding:NSUTF8StringEncoding];
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    NSDictionary *headers =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithFormat:@"Basic %@", base64Encoded],   @"Authorization",
     nil];
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:headers
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSString* response = [[NSString alloc] initWithData:c.responseData encoding:NSUTF8StringEncoding];
                           return response;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSString *result = (NSString*)c.parseResult;
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                      if ([result containsString:@"RestException"]) {
                          [self messageAlert:@"Failed to invited tipper"];
                      } else {
                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notification" message:@"Successfully invited tipper" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                          [alert show];
                      }
                      
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}

#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if ([text isEqualToString:@"Successfully invited tipper"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

@end
