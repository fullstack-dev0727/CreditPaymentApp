//
//  ProviderMainViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HMPopUpView.h"

@interface ProviderMainViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *budgetLabel;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UITableView *historyTableView;
    float totalBudget;
    PFObject* currentBudgetObject;
}
- (IBAction)onMenuClick:(id)sender;
- (IBAction)onWithdrawClick:(id)sender;
- (IBAction)onInviteUserClick:(id)sender;
@property (nonatomic, strong) NSArray* historyTransactions;
@end
