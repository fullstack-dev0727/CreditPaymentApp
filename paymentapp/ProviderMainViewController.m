//
//  ProviderMainViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "ProviderMainViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "MBProgressHUD.h"
#import "FSNConnection.h"
#import "AppDelegate.h"

@interface ProviderMainViewController ()
@property (nonatomic) FSNConnection *connection;
@end

@implementation ProviderMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _historyTransactions = [[NSArray alloc] init];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    PFUser* currentUser = [PFUser currentUser];
    PFFile* photo = currentUser[@"photo"];
    [profileImageView setImage:[UIImage imageWithData:photo.getData]];
    [nameLabel setText:[NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]]];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery* budgetQuery = [PFQuery queryWithClassName:@"Budgets"];
    [budgetQuery whereKey:@"provider_id" equalTo:currentUser.objectId];
    [budgetQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects != nil && [objects count] > 0) {
                currentBudgetObject = [objects objectAtIndex:0];
                totalBudget = [currentBudgetObject[@"budget"] floatValue];
                [budgetLabel setText:[NSString stringWithFormat:@"$%.1f", totalBudget]];
            }
        } else {
            
        }
    }];
    PFQuery *query = [PFQuery queryWithClassName:@"Transactions"];
    [query whereKey:@"phone" equalTo:currentUser[@"phone"]];
    [query orderByDescending:@"updatedAt"];
    query.limit = 5;
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

- (IBAction)onWithdrawClick:(id)sender {
    if (totalBudget <= 0) {
        [self messageAlert:@"Earn tips to withdraw funds"];
        return;
    }
    AppDelegate *appDelegate = APPDELEGATE;
    if ([appDelegate getPaymentInfo:ROUTINGNUMBER] == nil) {
        [self messageAlert:@"Please set bank account information."];
        return;
    }
    if (TESTMODE) {
        [self withdrawPaymentFunc];
    } else {
        [self.connection cancel];
        self.connection = [self withdrawPayment];
        [self.connection start];
    }
}

- (IBAction)onInviteUserClick:(id)sender {
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
    static NSString *cellIdentifier = @"main_history_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    UILabel* usernameLabel = (UILabel*) [cell.contentView viewWithTag:200];
    UILabel* dateLabel = (UILabel*) [cell.contentView viewWithTag:201];
    UILabel* priceLabel = (UILabel*) [cell.contentView viewWithTag:202];

    PFObject* historyObject = _historyTransactions[indexPath.row];
    
    [usernameLabel setText:[NSString stringWithFormat:@"%@", historyObject[@"user_name"]]];
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
- (void) withdrawPaymentFunc {
    if (currentBudgetObject != nil) {
        currentBudgetObject[@"budget"] = @0;
        [currentBudgetObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                totalBudget = 0;
                [budgetLabel setText:[NSString stringWithFormat:@"$%.1f", totalBudget]];
                [self messageAlert:@"Success to withdraw money"];
            } else {
                [self messageAlert:@"Failed to withdraw money"];
            }
        }];
    }

}
#pragma mark - FSConnection Functions
- (FSNConnection *) withdrawPayment {
    PFUser* currentUser = [PFUser currentUser];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",SERVER_BANK_URL]];
    AppDelegate* appDelegate = APPDELEGATE;
    NSString* routing_number = [appDelegate getPaymentInfo:ROUTINGNUMBER];
    NSString* account_number = [appDelegate getPaymentInfo:BANKACCOUNT];
    NSString* name = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstname"], currentUser[@"lastname"]];
    NSString* amount = [NSString stringWithFormat:@"%.1f", totalBudget];
    NSDictionary *parameters =
    [NSDictionary dictionaryWithObjectsAndKeys:
     name,                  @"name",
     currentUser.email,     @"email",
     amount,               @"amount",
     routing_number,        @"routing_number",
     account_number,        @"account_number",
     nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSLog(@"%@",[NSString stringWithUTF8String:[c.responseData bytes]]);
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      NSLog(@"complete: %@\n\nerror: %@\n\n", c, c.error);
                      NSDictionary *result = (NSDictionary*)c.parseResult;
                      NSLog(@"%@", result);
                      NSString* status = result[@"status"];
                      if (status != nil && [status isEqualToString:@"success"]) {
                          [self withdrawPaymentFunc];
                      } else{
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          [self messageAlert:@"Failed to withdraw money"];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}

@end
