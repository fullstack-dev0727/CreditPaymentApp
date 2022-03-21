//
//  ChooseCreditCard1ViewController.h
//  paymentapp
//
//  Created by Administrator on 2/12/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKCardNumberField.h"
#import "BKCardExpiryField.h"
#import "HMPopUpView.h"

@interface ChooseCreditCard1ViewController : UIViewController <UITextFieldDelegate, HMPopUpViewDelegate>{
    
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet BKCardNumberField *creditCardTextField;
    __weak IBOutlet UITextField *ccvTextField;
    __weak IBOutlet BKCardExpiryField *expiredTextField;
    __weak IBOutlet UIButton *menuButton;
    UITapGestureRecognizer* tapGesture;
    __weak IBOutlet UIScrollView *contentScrollView;
    CGPoint svos;
}
- (IBAction)onSaveClick:(id)sender;
- (IBAction)onMenuClick:(id)sender;


@end
