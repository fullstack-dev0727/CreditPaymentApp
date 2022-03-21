//
//  PaymentViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//
#import "UIView+NUI.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FPPopoverController.h"
#import "DropMenuTableViewController.h"
#import "HMPopUpView.h"

@interface PaymentViewController : UIViewController <UITextFieldDelegate, DropDoneMenuDelegate, HMPopUpViewDelegate>{
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *codeLabel;
    __weak IBOutlet UIImageView *accountConnectImageView;
    __weak IBOutlet UITextField *amountTextField;
    UITapGestureRecognizer* tapGesture;
    FPPopoverController *popoverAmountMenu;
    int amount;
    
}
@property (nonatomic, strong) PFUser *providerUser;
- (IBAction)onBackClick:(id)sender;
- (IBAction)onMoneyClick:(id)sender;
- (void) messageAlert: (NSString*) msg;
- (IBAction)onAmountClick:(id)sender;

@end
