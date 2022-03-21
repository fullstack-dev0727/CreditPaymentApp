//
//  InviteProviderViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "InviteProviderViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FSNConnection.h"
#import <Parse/Parse.h>
#import "DropMenuTableViewController.h"
#import "FPPopoverView.h"

@interface InviteProviderViewController ()
@property (nonatomic) FSNConnection *connection;
@end

@implementation InviteProviderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [phoneTextField.formatter setDefaultOutputPattern:@"### - ### - ####"];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
}
- (void) tapView:(UITapGestureRecognizer*)gesture {
    if ( tapGesture ) {
        [phoneTextField resignFirstResponder];
        [amountTextField resignFirstResponder];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onInviteClick:(id)sender {
    if ([phoneTextField.text length] > 0){
        [self sendInviteWithSMS];
        return;
    }
    [self messageAlert:@"Please input phone number"];
    
}

- (void) sendPaymentMoney {
    float amount1 = 95 * amount / 100.0f;
    NSString* phoneNumber = [[phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    PFUser* currentUser = [PFUser currentUser];
    PFObject* transactionObject = [PFObject objectWithClassName: @"Transactions"];
    transactionObject[@"user_id"] = currentUser.objectId;
    transactionObject[@"user_name"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
    transactionObject[@"provider_id"] = @"";
    transactionObject[@"provider_name"] = @"";
    transactionObject[@"price"] = @(amount1);
    transactionObject[@"phone"] = phoneNumber;
    
    [transactionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (!error) {
            HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:@"Transaction complete. User will receive funds upon sign up" cancelButtonTitle:@"Ok" delegate:self];
            [hmPopUp showInView:self.view];
        } else {
            [self messageAlert:@"Failed to send funds"];
        }
    }];
}
- (void) sendInviteWithSMS {
    [self.connection cancel];
    self.connection = [self smsConnection];
    [self.connection start];
}

- (IBAction)onAmountClick:(id)sender {
    DropMenuTableViewController* dropmenuTableviewController = [[DropMenuTableViewController alloc] init];
    [dropmenuTableviewController setMenuArray: [@[@"$ 1", @"$ 2", @"$ 5", @"$ 10", @"$ 20"] mutableCopy]];
    dropmenuTableviewController.delegate = self;
    popoverAmountMenu = [[FPPopoverController alloc] initWithViewController:dropmenuTableviewController];
    popoverAmountMenu.border = NO;
    popoverAmountMenu.contentSize = CGSizeMake(100,220);
    [popoverAmountMenu.view setNuiClass:@"DropDownView"];
    
    [popoverAmountMenu presentPopoverFromView:amountTextField];
}
- (void)selectAmount:(NSString*) amount1 {
    [amountTextField setText:amount1];
    [popoverAmountMenu dismissPopoverAnimated:YES];
}
#pragma mark - FSConnection Functions
- (FSNConnection *)smsConnection {
    NSString* phoneNumber = [[phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    PFUser* currentUser = [PFUser currentUser];
    NSString* msg = [NSString stringWithFormat:@"%@ %@ has invited you to the application.\n%@", currentUser[@"firstname"], currentUser[@"lastname"], IOS_APP_LINK];
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
                      
                      if ([result containsString:@"RestException"]) {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          [self messageAlert:@"Provider has not been invited!"];
                      } else {
                          
                          if ([amountTextField.text length] == 0 ) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:@"Provider has been invited!" cancelButtonTitle:@"Ok" delegate:self];
                              [hmPopUp showInView:self.view];
                              return;
                          }
                          NSString* amountValue = [amountTextField.text substringFromIndex:2];
                          amount = [amountValue intValue];
                          AppDelegate* appDelegate = APPDELEGATE;
                          
                          if ([appDelegate getPaymentInfo:CREDITCARDNUMBER] == nil) {
                              [self messageAlert:@"Please set your credit card information"];
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              return;
                          }
                          if (TESTMODE) {
                              [self sendPaymentMoney];
                          } else {
                              
                              [self.connection cancel];
                              self.connection = [self sendPayment];
                              [self.connection start];
                          }

                      }
                      
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (IBAction)onMenuClick:(id)sender {
     [self.sidePanelController toggleLeftPanel:nil];
}

- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}
#pragma mark -
#pragma mark UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - FSConnection Functions
- (FSNConnection *)sendPayment {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SERVER_STRIPE_URL]];
    AppDelegate* appDelegate = APPDELEGATE;
    NSString* cc_number = [appDelegate getPaymentInfo:CREDITCARDNUMBER];
    NSString* cvc = [appDelegate getPaymentInfo:CVCNUMBER];
    NSString* exp_month = [appDelegate getPaymentInfo:EXPIREDMONTH];
    NSString* exp_year = [appDelegate getPaymentInfo:EXPIREDYEAR];
    NSString* amount1 = [NSString stringWithFormat:@"%d", amount];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     cc_number,     @"cc_number",
     exp_month,     @"exp_month",
     exp_year,      @"exp_year",
     cvc,           @"cvc",
     amount1,        @"amount",
     nil];
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
                      NSString* status = result[@"status"];
                      
                      if (status != nil && [status isEqualToString:@"success"]) {
                          [self sendPaymentMoney];
                      } else{
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                          });
                          
                          [self messageAlert:@"Failed to send funds"];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}
#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if (!accept) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
