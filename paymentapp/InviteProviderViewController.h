//
//  InviteProviderViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHSPhoneTextField.h"
#import "FPPopoverController.h"
#import "DropMenuTableViewController.h"
#import "HMPopUpView.h"

@interface InviteProviderViewController : UIViewController <UITextFieldDelegate, DropDoneMenuDelegate, HMPopUpViewDelegate>{
    __weak IBOutlet SHSPhoneTextField *phoneTextField;
    __weak IBOutlet UITextField *amountTextField;
    NSString* inviteMessage;
    UITapGestureRecognizer* tapGesture;
    FPPopoverController *popoverAmountMenu;
    int amount;
}
- (IBAction)onInviteClick:(id)sender;
- (IBAction)onMenuClick:(id)sender;
- (void) sendInviteWithSMS;
- (IBAction)onAmountClick:(id)sender;
@end
