//
//  ProfileViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SHSPhoneTextField.h"
#import "HMPopUpView.h"

@interface ProfileViewController : UIViewController <HMPopUpViewDelegate> {
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UILabel *codeLabel;
    
    __weak IBOutlet SHSPhoneTextField *phoneLabel;
    __weak IBOutlet UIView *usernameView;
    __weak IBOutlet UIView *emailView;
    __weak IBOutlet UIView *phoneView;
    __weak IBOutlet UIView *locationView;
    __weak IBOutlet UIView *typeView;
    __weak IBOutlet UIView *codeView;
    PFUser* providerUser;
}
- (IBAction)onMenuClick:(id)sender;
- (IBAction)onSignoutClick:(id)sender;


@end
