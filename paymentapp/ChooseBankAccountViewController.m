//
//  ChooseBankAccountViewController.m
//  paymentapp
//
//  Created by Administrator on 2/6/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "ChooseBankAccountViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "UserMapViewController.h"

@interface ChooseBankAccountViewController ()

@end

@implementation ChooseBankAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate* appDelegate = APPDELEGATE;
    if ([appDelegate getPaymentInfo:BANKACCOUNT] != nil) {
        [bankaccountField setText:@"●●●●●●●●●●●●"];
        [routingField setText:@"●●●●●●●●●"];
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

- (IBAction)onSaveButtonClick:(id)sender {
    if ([bankaccountField.text length] < 12) {
        [self messageAlert:@"Please input valid bank account number"];
        return;
    }
    if ([routingField.text length] < 9) {
        [self messageAlert:@"Please input valid routing number"];
        return;
    }
    AppDelegate* appDelegate = APPDELEGATE;
    if ([bankaccountField.text isEqualToString:@"●●●●●●●●●●●●"] && [routingField.text isEqualToString:@"●●●●●●●●●" ]) {
        
    } else if ([bankaccountField.text isEqualToString:@"●●●●●●●●●●●●"] && ![routingField.text containsString:@"●"]) {
        [appDelegate setPaymentInfo:ROUTINGNUMBER value:routingField.text];
    } else if ([routingField.text isEqualToString:@"●●●●●●●●●"] && ![bankaccountField.text containsString:@"●"]) {
        [appDelegate setPaymentInfo:BANKACCOUNT value:bankaccountField.text];
    } else if ([routingField.text containsString:@"●"] || [bankaccountField.text containsString:@"●"]) {
        [self messageAlert:@"Please enter valid informations"];
        return;
    } else {
        [appDelegate setPaymentInfo:BANKACCOUNT value:bankaccountField.text];
        [appDelegate setPaymentInfo:ROUTINGNUMBER value:routingField.text];
    }
    [self messageAlert:@"Saved"];
    [bankaccountField setText:@"●●●●●●●●●●●●"];
    [routingField setText:@"●●●●●●●●●"];
}

- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    AppDelegate* appDelegate = APPDELEGATE;
    if (textField == bankaccountField) {
        if ([[appDelegate getPaymentInfo:BANKACCOUNT] length] > 0) {
            [bankaccountField setText:[appDelegate getPaymentInfo:BANKACCOUNT]];
        }
    } else {
        if ([[appDelegate getPaymentInfo:ROUTINGNUMBER] length] > 0) {
            [routingField setText:[appDelegate getPaymentInfo:ROUTINGNUMBER]];
        }
        
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == bankaccountField) {
        [routingField becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
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
