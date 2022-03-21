//
//  ChooseCreditCard1ViewController.m
//  paymentapp
//
//  Created by Administrator on 2/12/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "ChooseCreditCard1ViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "AppDelegate.h"
#import "UserMapViewController.h"

@interface ChooseCreditCard1ViewController ()

@end

@implementation ChooseCreditCard1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    creditCardTextField.showsCardLogo = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
    AppDelegate *appDelegate = APPDELEGATE;
    NSString* creditCard = [appDelegate getPaymentInfo:CREDITCARDNUMBER];
    if ([creditCard length] > 0) {
        [creditCardTextField setText:[NSString stringWithFormat:@"●●●● ●●●● ●●●● %@", [creditCard substringWithRange:NSMakeRange(12, 4)]]];
        [ccvTextField setText: [ccvTextField.text length] == 3 ? @"●●●" : @"●●●●"];
        [expiredTextField setText:[NSString stringWithFormat:@"%@ / %@", [appDelegate getPaymentInfo:EXPIREDMONTH], [[appDelegate getPaymentInfo:EXPIREDYEAR] substringFromIndex:2] ]];
    }
}
- (void) tapView:(UITapGestureRecognizer*)gesture {
    if ( tapGesture ) {
        [creditCardTextField resignFirstResponder];
        [ccvTextField resignFirstResponder];
        [expiredTextField resignFirstResponder];

        CGPoint pt;
        CGRect rc = [expiredTextField bounds];
        rc = [expiredTextField convertRect:rc toView:contentScrollView];
        pt = rc.origin;
        pt.x = 0;
        pt.y = 0;
        [contentScrollView setContentOffset:pt animated:YES];
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

- (IBAction)onSaveClick:(id)sender {
    if ([creditCardTextField.cardNumber length] < 12 && ![creditCardTextField.text containsString:@"●"])  {
        [self messageAlert:@"Please input valid Credit Card Number"];
        return;
    }
    if ([ccvTextField.text length] == 0 || [ccvTextField.text length] < 3) {
        [self messageAlert:@"Please input valid CCV"];
        return;
    }
    NSDateComponents *dateComp = expiredTextField.dateComponents;
    NSInteger month = dateComp.month;
    NSInteger year = dateComp.year;
    if (month == 0 || year == 0) {
        [self messageAlert:@"Please input expired date"];
        return;
    }
    AppDelegate* appDelegate = APPDELEGATE;
    if (![creditCardTextField.text containsString:@"●"])
        [appDelegate setPaymentInfo:CREDITCARDNUMBER value:creditCardTextField.cardNumber];
    if (![ccvTextField.text containsString:@"●"]) {
        [appDelegate setPaymentInfo:CVCNUMBER value:ccvTextField.text];
    }

    [appDelegate setPaymentInfo:EXPIREDYEAR value:[NSString stringWithFormat:@"%d",year]];
    [appDelegate setPaymentInfo:EXPIREDMONTH value:[NSString stringWithFormat:@"%d", month]];
    NSString* creditCard = [appDelegate getPaymentInfo:CREDITCARDNUMBER];
    [creditCardTextField setText:[NSString stringWithFormat:@"●●●● ●●●● ●●●● %@", [creditCard substringWithRange:NSMakeRange(12, 4)]]];
    [ccvTextField setText: [ccvTextField.text length] == 3 ? @"●●●" : @"●●●●"];
    
    [self messageAlert:@"You have successfully linked your card"];

}
- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}

#pragma mark - textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == creditCardTextField) {
        NSString *cardCompany = creditCardTextField.cardCompanyName;
        if ([string length] > 0 && [creditCardTextField.text length] > 3 && nil == cardCompany) {
            return NO;
        }
    } else if (textField == ccvTextField) {
        if ([string length] > 0 && [ccvTextField.text length] > 3)
            return NO;
    } else if (textField == expiredTextField) {
        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == creditCardTextField) {
        [ccvTextField becomeFirstResponder];
        return YES;
    }
    if (textField == ccvTextField) {
        [expiredTextField becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    svos = contentScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:contentScrollView];
    pt = rc.origin;
    pt.x = 0;
    AppDelegate *appDelegate = APPDELEGATE;
    if (textField == creditCardTextField) {
        pt.y = 0;
        NSString* creditCard = [appDelegate getPaymentInfo:CREDITCARDNUMBER];
        if ([creditCard length] > 0) {
            NSString* formattedVal = [NSString stringWithFormat:@"%@ %@ %@ %@", [creditCard substringWithRange:NSMakeRange(0, 4)], [creditCard substringWithRange:NSMakeRange(4, 4)], [creditCard substringWithRange:NSMakeRange(8, 4)], [creditCard substringWithRange:NSMakeRange(12, 4)]];
            [creditCardTextField setText:formattedVal];
        }
    } else {
        pt.y -= 60;
        if ([[appDelegate getPaymentInfo:CVCNUMBER] length] > 0) {
            [ccvTextField setText:[appDelegate getPaymentInfo:CVCNUMBER]];
        }
    }
    
    [contentScrollView setContentOffset:pt animated:YES];
    return YES;
}
- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:self];
    [hmPopUp showInView:self.view];
}
#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if (!accept) {
        AppDelegate* appDelegate = APPDELEGATE;
        if ([appDelegate isUserAccount]) {
            UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"usermapviewcontroller"];
            UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
            if (![[navVC topViewController] isMemberOfClass:[UserMapViewController class]]) {
                [navVC pushViewController:VC animated:YES];
            }
            
        } else {
            UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"providerviewcontroller"];
            UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
            if (![[navVC topViewController] isMemberOfClass:[UserMapViewController class]]) {
                [navVC pushViewController:VC animated:YES];
            }
        }
    }
}



@end
