//
//  MenuViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UITableView *menuTableView;
}

@end
