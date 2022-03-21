//
//  PaymentViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "PaymentViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import <Parse/Parse.h>
#import "FSNConnection.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "DropMenuTableViewController.h"

@interface PaymentViewController ()
@property (nonatomic) FSNConnection *connection;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_providerUser == nil)
        return;
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    PFFile* photo = _providerUser[@"photo"];
    [profileImageView setImage:[UIImage imageWithData:photo.getData]];
    
    [usernameLabel setText:[NSString stringWithFormat:@"%@ %@", _providerUser[@"firstname"], _providerUser[@"lastname"]]];
    [locationLabel setText:_providerUser[@"location"]];
    [typeLabel setText:_providerUser[@"type"]];
    [codeLabel setText:_providerUser[@"code"]];
    
    AppDelegate* appDelegate = APPDELEGATE;
    if ([appDelegate getPaymentInfo:CREDITCARDNUMBER] == nil) {
        [accountConnectImageView setImage:[UIImage imageNamed:@"icon_check_unselected.png"]];
    } else {
        [accountConnectImageView setImage:[UIImage imageNamed:@"icon_check_selected.png"]];
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


- (IBAction)onBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onMoneyClick:(id)sender {
    if ([amountTextField.text length] == 0) {
        [self messageAlert:@"Please input amount to send"];
        return;
    }
    NSString* amountValue = [amountTextField.text substringFromIndex:2];
    amount = [amountValue intValue];
//    if (amount < 20) {
//        [self messageAlert:@"Please input above $20"];
//        return;
//    }
    AppDelegate* appDelegate = APPDELEGATE;
    
    if ([appDelegate getPaymentInfo:CREDITCARDNUMBER] == nil) {
        [self messageAlert:@"Please set your credit card information"];
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
- (void) sendPaymentMoney {
    PFUser* currentUser = [PFUser currentUser];
    PFObject* transactionObject = [PFObject objectWithClassName: @"Transactions"];
    transactionObject[@"user_id"] = currentUser.objectId;
    transactionObject[@"user_name"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
    transactionObject[@"provider_id"] = _providerUser.objectId;
    transactionObject[@"provider_name"] = [NSString stringWithFormat:@"%@ %@", _providerUser[@"firstname"], _providerUser[@"lastname"]];
    transactionObject[@"price"] = @(amount);
    transactionObject[@"phone"] = _providerUser[@"phone"];
    [transactionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFQuery* budgetQuery = [PFQuery queryWithClassName:@"Budgets"];
            [budgetQuery whereKey:@"provider_id" equalTo:_providerUser.objectId];
            [budgetQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                float amount1 = 95 * amount / 100.0f;
                if (objects != nil && [objects count] > 0) {
                    PFObject* item = [objects objectAtIndex:0];
                    int currentBudget = [item[@"budget"] integerValue];
                    item[@"budget"] = @(currentBudget + amount1);
                    [item save];
                } else {
                    PFObject* item = [PFObject objectWithClassName:@"Budgets"];
                    item[@"provider_id"] = _providerUser.objectId;
                    item[@"budget"] = @(amount1);
                    [item save];
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self messageAlert:@"Success to send money"];
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self messageAlert:@"Failed to send money."];
        }
    }];
}

- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}

#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if ([text isEqualToString:@"Success to send money"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
- (void)selectAmount:(NSString*) amount {
    [amountTextField setText:amount];
    [popoverAmountMenu dismissPopoverAnimated:YES];
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ( !tapGesture ) {
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self.view addGestureRecognizer:tapGesture];
        
        [self scrollContent:-150];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ( textField == amountTextField ) {
        [amountTextField resignFirstResponder];
        [self tapView:nil];
    }
    return YES;
}

- (void) tapView:(UITapGestureRecognizer*)gesture {
    if ( tapGesture ) {
        
        [self scrollContent:150];
        
        [amountTextField resignFirstResponder];
        
        [self.view removeGestureRecognizer:tapGesture];
        tapGesture = nil;
    }
}

- (void) scrollContent:(int)offsetY {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rtView = self.view.frame;
                         rtView.origin.y += offsetY;
                         
                         self.view.frame = rtView;
                     }];
}
#pragma mark - FSConnection Functions
- (FSNConnection *)sendPayment {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SERVER_STRIPE_URL]];
    AppDelegate* appDelegate = APPDELEGATE;
    NSString* cc_number = [appDelegate getPaymentInfo:CREDITCARDNUMBER];
    NSString* cvc = [appDelegate getPaymentInfo:CVCNUMBER];
    NSString* exp_month = [appDelegate getPaymentInfo:EXPIREDMONTH];
    NSString* exp_year = [appDelegate getPaymentInfo:EXPIREDYEAR];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     cc_number,     @"cc_number",
     exp_month,     @"exp_month",
     exp_year,      @"exp_year",
     cvc,           @"cvc",
     @(amount),        @"amount",
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
                      NSString* status = result[@"status"];
                      if (status != nil && [status isEqualToString:@"success"]) {
                          [self sendPaymentMoney];
                      } else{
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          [self messageAlert:@"Failed to send money"];
                      }
                   }
                   progressBlock:^(FSNConnection *c) {
                       NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                   }];
}

@end
