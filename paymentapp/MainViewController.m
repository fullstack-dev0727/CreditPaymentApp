//
//  MainViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/30/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
-(void)awakeFromNib{

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    if (_isUser) {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier: @"userCenterViewController"]];
    } else {
        [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier: @"providerCenterViewController"]];
    }
    
    self.panningLimitedToTopViewController = NO;
    
}
- (void)stylePanel:(UIView *)panel {
    [super stylePanel:panel];
    
    [panel.layer setCornerRadius:0.0f];
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

@end
