//
//  InviteUserViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHSPhoneTextField.h"
#import "HMPopUpView.h"

@interface InviteUserViewController : UIViewController <UITextFieldDelegate, HMPopUpViewDelegate> {
    
    __weak IBOutlet UITextField *emailTextField;
    __weak IBOutlet SHSPhoneTextField *phoneTextField;
    NSString* inviteMessage;
    UITapGestureRecognizer* tapGesture;
}
- (IBAction)onMenuClick:(id)sender;
- (IBAction)onSendInviteClick:(id)sender;
- (void) messageAlert: (NSString*) msg;
- (void) sendInviteWithSMS;
@end
