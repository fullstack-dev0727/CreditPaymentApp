//
//  ChooseBankAccountViewController.h
//  paymentapp
//
//  Created by Administrator on 2/6/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HMPopUpView.h"

@interface ChooseBankAccountViewController : UIViewController <UITextFieldDelegate, HMPopUpViewDelegate> {
    
    __weak IBOutlet UITextField *bankaccountField;
    __weak IBOutlet UITextField *routingField;
}
- (IBAction)onSaveButtonClick:(id)sender;
- (IBAction)onMenuClick:(id)sender;

@end
