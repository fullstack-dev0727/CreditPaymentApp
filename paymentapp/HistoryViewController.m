//
//  HistoryViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "HistoryViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate* appDelegate = APPDELEGATE;
    PFUser* currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Transactions"];
    if ([appDelegate isUserAccount]) {
        [query whereKey:@"user_id" equalTo:currentUser.objectId];
    } else {
        [query whereKey:@"phone" equalTo:currentUser[@"phone"]];
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            if ([objects count] > 0) {
                _historyTransactions = objects;
                [historyTableView reloadData];
            }
        } else {
            
        }
    }];
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


#pragma mark - UITableView Delegate & Datasrouce -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_historyTransactions count] > 0)
        return [_historyTransactions count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel* nameLabel = (UILabel*) [cell.contentView viewWithTag:100];
    UILabel* dateLabel = (UILabel*) [cell.contentView viewWithTag:101];
    UILabel* priceLabel = (UILabel*) [cell.contentView viewWithTag:102];
    
    PFObject* historyObject = _historyTransactions[indexPath.row];
    AppDelegate* appDelegate = APPDELEGATE;
    [nameLabel setText:[NSString stringWithFormat:@"%@", historyObject[[appDelegate isUserAccount] ? @"provider_name" : @"user_name"]]];
    NSDate* date = historyObject.createdAt;
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMM yyyy"];
    [dateLabel setText:[format stringFromDate:date]];
    [priceLabel setText:[NSString stringWithFormat:@"$%@", historyObject[@"price"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}

@end
