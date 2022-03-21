//
//  MenuViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "MenuViewController.h"
#import "ChooseBankAccountViewController.h"
#import "ChooseCreditCard1ViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "UserMapViewController.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"menucell"];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    PFUser* currentUser = [PFUser currentUser];
    PFFile* photo = currentUser[@"photo"];
    [profileImageView setImage:[UIImage imageWithData:photo.getData]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Delegate & Datasrouce -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"menuTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIImageView* menuImageView = (UIImageView*) [cell.contentView viewWithTag:300];
    switch (indexPath.row)
    {
        case 0:
            [menuImageView setImage:[UIImage imageNamed:@"menu_icon_map.png"]];
            break;
        case 1:
            [menuImageView setImage:[UIImage imageNamed:@"menu_icon_credit.png"]];
            break;
        case 2:
            [menuImageView setImage:[UIImage imageNamed:@"menu_icon_profile.png"]];
            break;
        case 3:
            [menuImageView setImage:[UIImage imageNamed:@"menu_icon_history.png"]];
            break;
        case 4:
            [menuImageView setImage:[UIImage imageNamed:@"menu_icon_help.png"]];
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0: {
            [self.sidePanelController showCenterPanelAnimated:YES];
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
            break;
        case 1: {
            [self.sidePanelController showCenterPanelAnimated:YES];
            AppDelegate* appDelegate = APPDELEGATE;
            if ([appDelegate isUserAccount]) {
                UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"choosecreditcard1viewcontroller"];
                UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
                if (![[navVC topViewController] isMemberOfClass:[ChooseCreditCard1ViewController class]]) {
                    [navVC pushViewController:VC animated:YES];
                }
                
            } else {
                UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"choosebankaccountviewcontroller"];
                UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
                if (![[navVC topViewController] isMemberOfClass:[ChooseBankAccountViewController class]]) {
                    [navVC pushViewController:VC animated:YES];
                }
            }
        }
            break;
        case 2: {
            [self.sidePanelController showCenterPanelAnimated:YES];
            UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"profileviewcontroller"];
            UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
            if (![[navVC topViewController] isMemberOfClass:[ProfileViewController class]]) {
                [navVC pushViewController:VC animated:YES];
            }
        }
            break;
        case 3: {
            [self.sidePanelController showCenterPanelAnimated:YES];
            UIViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"historyviewcontroller"];
            UINavigationController *navVC = (UINavigationController*)self.sidePanelController.centerPanel;
            if (![[navVC topViewController] isMemberOfClass:[HistoryViewController class]]) {
                [navVC pushViewController:VC animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
