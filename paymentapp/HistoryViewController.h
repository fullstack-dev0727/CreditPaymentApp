//
//  HistoryViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UITableView *historyTableView;
}
- (IBAction)onMenuClick:(id)sender;
@property (nonatomic, strong) NSArray* historyTransactions;
@end
