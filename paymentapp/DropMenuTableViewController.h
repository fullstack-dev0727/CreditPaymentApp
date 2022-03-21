//
//  DropMenuTableViewController.h
//  paymentapp
//
//  Created by Administrator on 2/13/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DropDoneMenuDelegate

- (void)selectAmount:(NSString*) amount;

@end
@interface DropMenuTableViewController : UITableViewController {
    
}
@property (weak, nonatomic) id<DropDoneMenuDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *menuArray;
- (void) setMenuArray: (NSMutableArray*) array;
@end
