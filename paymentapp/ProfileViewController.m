//
//  ProfileViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GuideViewController.h"

@interface ProfileViewController () <UIAlertViewDelegate>

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    PFUser* currentUser = [PFUser currentUser];
    PFFile* photo = currentUser[@"photo"];
    [profileImageView setImage:[UIImage imageWithData:photo.getData]];
    
    AppDelegate* appDelegate = APPDELEGATE;
    if ([appDelegate isUserAccount]) {
        [locationView setHidden:TRUE];
        [typeView setHidden:TRUE];
        [codeView setHidden:TRUE];
        [usernameView setBackgroundColor:[UIColor colorWithRed:0 green:0.63f blue:0.69f alpha:1]];
        [emailView setBackgroundColor:[UIColor colorWithRed:0.92f green:0.8f blue:0.4f alpha:1]];
        [phoneView setBackgroundColor:[UIColor colorWithRed:0.96f green:0.32f blue:0.31f alpha:1]];
    } else {
        [locationLabel setText:currentUser[@"location"]];
        [typeLabel setText:currentUser[@"type"]];
        [codeLabel setText:currentUser[@"code"]];
    }
    [usernameLabel setText: [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]]];
    [emailLabel setText:currentUser.email];
    [phoneLabel.formatter setDefaultOutputPattern:@"### - ### - ###"];
    NSString* phonenumber = currentUser[@"phone"];
    if ([phonenumber length] == 10) {
        NSString* formatNumber = [NSString stringWithFormat:@"%@ - %@ - %@", [phonenumber substringWithRange:NSMakeRange(0, 3)], [phonenumber substringWithRange:NSMakeRange(3, 3)], [phonenumber substringWithRange:NSMakeRange(5, 4)]];
        [phoneLabel setText:formatNumber];
    } else {
        [phoneLabel setText:phonenumber];
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

- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}

- (IBAction)onSignoutClick:(id)sender {
    [self messageAlert:@"Are you sure you want to logout?"];
}
- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitleWithoutTextField:msg okButtonTitle:@"Ok" cancelButtonTitle:@"Cancel" delegate:self];
    [hmPopUp showInView:self.view];
}

#pragma mark - HMPopUpViewDelegate
-(void)popUpView:(HMPopUpView *)alertView accepted:(BOOL)accept inputText:(NSString *)text{
    if (accept) {
        PFUser* currentUser = [PFUser currentUser];
        if (currentUser) {
            [PFUser logOut];
            
        }
        
        AppDelegate* appDelegate = APPDELEGATE;
        [appDelegate setUsername:nil];
        [appDelegate setPassword:nil];
        [appDelegate setPaymentInfo:CREDITCARDNUMBER value:nil];
        [appDelegate setPaymentInfo:CVCNUMBER value:nil];
        [appDelegate setPaymentInfo:EXPIREDYEAR value:nil];
        [appDelegate setPaymentInfo:EXPIREDMONTH value:nil];
        [appDelegate setPaymentInfo:ROUTINGNUMBER value:nil];
        [appDelegate setPaymentInfo:BANKACCOUNT value:nil];
        GuideViewController *guideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"guideview"];
        UINavigationController* guideNav = [[UINavigationController alloc] initWithRootViewController:guideVC];
        guideNav.navigationBarHidden = TRUE;
        appDelegate.window.rootViewController = guideNav;
    } else {
        
    }
    
}

@end
