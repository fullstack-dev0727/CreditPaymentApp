//
//  SplashViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HMPopUpView.h"

@interface SplashViewController : UIViewController {
    
}
- (void) messageAlert: (NSString*) msg;
- (void) loginwithFacebook;

@end
