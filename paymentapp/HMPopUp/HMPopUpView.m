//
//  HMPopUpView.m
//  HMPopUp
//
//  Created by Himal Madhushan on 12/16/14.
//  Copyright (c) 2014 Himal Madhushan. All rights reserved.
//

#import "HMPopUpView.h"

@interface HMPopUpView (){
    UIView *HUD, *containerView, *separatorView, *buttonView;
    UILabel *lblTitle, *lblMessage;
    UIButton *btnOk, *btnCancel;
    UITextField *txtField;
}

@end

@implementation HMPopUpView

@synthesize hmDelegate = _hmDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithTitle:(NSString *)title okButtonTitle:(NSString *)okBtnTtl cancelButtonTitle:(NSString *)cnclBtnTtl delegate:(id<HMPopUpViewDelegate>)delegate {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        _hmDelegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        HUD = [[UIView alloc] initWithFrame:self.bounds];
        HUD.backgroundColor = [UIColor blackColor];
        HUD.alpha = .1;
        [self addSubview:HUD];
        
        //Creating the view which contains all ui components
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 10;
        containerView.clipsToBounds = YES;
        
        CGRect cnvwFrame = containerView.bounds;
        cnvwFrame.origin.x = self.frame.size.width / 2 - (cnvwFrame.size.width / 2);
        cnvwFrame.origin.y = self.frame.size.height / 2 - (cnvwFrame.size.height / 2);
        containerView.frame = cnvwFrame;
        [self addSubview:containerView];
        
        CGRect cvFrame = containerView.bounds;
        
        //Separator View creation
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 45, cvFrame.size.width, 1)];
        separatorView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:separatorView];
        
        //Title label
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x + 5, cvFrame.origin.y + 15, cvFrame.size.width - 10, 60)];
        lblTitle.numberOfLines = 2;
        lblTitle.text = title;
        lblTitle.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        lblTitle.textAlignment = NSTextAlignmentCenter;
//        lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        [containerView addSubview:lblTitle];
        
        //TextField for user inputs
        txtField = [[UITextField alloc] initWithFrame:CGRectMake(cvFrame.origin.x + 10, cvFrame.origin.y + 80, cvFrame.size.width - 20, 30)];
        txtField.textAlignment = NSTextAlignmentCenter;
        txtField.backgroundColor = [UIColor colorWithRed:0.162 green:0.718 blue:0.999 alpha:0.15];
        //txtField.layer.cornerRadius = 3;
        txtField.clipsToBounds = YES;
        txtField.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        txtField.tintColor = [UIColor blackColor];
        //txtField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        txtField.delegate = self;
        [containerView addSubview:txtField];
        
        //Button view creation
        buttonView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x , cvFrame.origin.y + 130, cvFrame.size.width, cvFrame.size.height - 130)];
        buttonView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:buttonView];
        
        //Action button creation
        btnOk = [[UIButton alloc] initWithFrame:CGRectMake(cvFrame.origin.x , cvFrame.origin.y + 131, cvFrame.size.width / 2 - 1, 39)];
        [btnOk setTitle:okBtnTtl forState:UIControlStateNormal];
        btnOk.backgroundColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        btnOk.titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        // btnOk.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:btnOk];
        [btnOk addTarget:self action:@selector(acceptAction) forControlEvents:UIControlEventTouchUpInside];
        
        
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(btnOk.frame.origin.x + btnOk.frame.size.width + 1, cvFrame.origin.y + 131, cvFrame.size.width / 2, 39)];
        [btnCancel setTitle:cnclBtnTtl forState:UIControlStateNormal];
        btnCancel.backgroundColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        btnCancel.titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        // btnCancel.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:btnCancel];
        [btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        //        [self addSubview:containerView];
        
    }
    
    return self;
}
-(id)initWithTitleWithoutTextField:(NSString *)title okButtonTitle:(NSString *)okBtnTtl cancelButtonTitle:(NSString *)cnclBtnTtl delegate:(id<HMPopUpViewDelegate>)delegate {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        _hmDelegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        HUD = [[UIView alloc] initWithFrame:self.bounds];
        HUD.backgroundColor = [UIColor blackColor];
        HUD.alpha = .1;
        [self addSubview:HUD];
        
        //Creating the view which contains all ui components
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 10;
        containerView.clipsToBounds = YES;
        
        CGRect cnvwFrame = containerView.bounds;
        cnvwFrame.origin.x = self.frame.size.width / 2 - (cnvwFrame.size.width / 2);
        cnvwFrame.origin.y = self.frame.size.height / 2 - (cnvwFrame.size.height / 2);
        containerView.frame = cnvwFrame;
        [self addSubview:containerView];
        
        CGRect cvFrame = containerView.bounds;
        
        //Separator View creation
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 45, cvFrame.size.width, 1)];
        separatorView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:separatorView];
        
        //Title label
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x + 10, cvFrame.origin.y + 7, cvFrame.size.width - 20, 50)];
        lblTitle.numberOfLines = 2;
        lblTitle.text = title;
        lblTitle.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        //lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:lblTitle];
        
        //Button view creation
        buttonView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x , cvFrame.origin.y + 130, cvFrame.size.width, cvFrame.size.height - 130)];
        buttonView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:buttonView];
        
        //Action button creation
        btnOk = [[UIButton alloc] initWithFrame:CGRectMake(cvFrame.origin.x , cvFrame.origin.y + 62, cvFrame.size.width / 2 - 1, 39)];
        [btnOk setTitle:okBtnTtl forState:UIControlStateNormal];
        btnOk.backgroundColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        btnOk.titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
       // btnOk.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:btnOk];
        [btnOk addTarget:self action:@selector(acceptAction) forControlEvents:UIControlEventTouchUpInside];
        
        
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(btnOk.frame.origin.x + btnOk.frame.size.width + 1, cvFrame.origin.y + 62, cvFrame.size.width / 2, 39)];
        [btnCancel setTitle:cnclBtnTtl forState:UIControlStateNormal];
        btnCancel.backgroundColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        btnCancel.titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
       // btnCancel.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:btnCancel];
        [btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
//        [self addSubview:containerView];
        
    }
    
    return self;
}
-(id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cnclBtnTtl delegate:(id<HMPopUpViewDelegate>)delegate {
    
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (self) {
        _hmDelegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        HUD = [[UIView alloc] initWithFrame:self.bounds];
        HUD.backgroundColor = [UIColor blackColor];
        HUD.alpha = .1;
        [self addSubview:HUD];
        
        //Creating the view which contains all ui components
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 10;
        containerView.clipsToBounds = YES;
        
        CGRect cnvwFrame = containerView.bounds;
        cnvwFrame.origin.x = self.frame.size.width / 2 - (cnvwFrame.size.width / 2);
        cnvwFrame.origin.y = self.frame.size.height / 2 - (cnvwFrame.size.height / 2);
        containerView.frame = cnvwFrame;
        [self addSubview:containerView];
        
        CGRect cvFrame = containerView.bounds;
        
        //Separator View creation
        separatorView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x, cvFrame.origin.y + 45, cvFrame.size.width, 1)];
        separatorView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:separatorView];
        
        //Title label
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(cvFrame.origin.x + 10, cvFrame.origin.y + 7, cvFrame.size.width - 20, 50)];
        lblTitle.numberOfLines = 2;
        lblTitle.text = title;
        lblTitle.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        //lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:lblTitle];
        
        
        //Button view creation
        buttonView = [[UIView alloc] initWithFrame:CGRectMake(cvFrame.origin.x , cvFrame.origin.y + 130, cvFrame.size.width, cvFrame.size.height - 130)];
        buttonView.backgroundColor = [UIColor whiteColor];
        [containerView addSubview:buttonView];
        
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, cvFrame.origin.y + 62, cvFrame.size.width, 39)];
        [btnCancel setTitle:cnclBtnTtl forState:UIControlStateNormal];
        btnCancel.backgroundColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        btnCancel.titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.8f blue:0.9f alpha:1.0f];
        // btnCancel.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [containerView addSubview:btnCancel];
        [btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        
        //        [self addSubview:containerView];
        
    }
    
    return self;
}

-(void)configureHMPopUpViewWithBGColor:(UIColor *)BGColor titleColor:(UIColor *)ttlColor buttonViewColor:(UIColor *)btnViewColor buttonBGColor:(UIColor *)btnBGColor buttonTextColor:(UIColor *)btnTxtColor {
    
    containerView.backgroundColor = BGColor;
    lblTitle.textColor = ttlColor;
    buttonView.backgroundColor = btnViewColor;
    
    btnOk.backgroundColor = btnBGColor;
    btnCancel.backgroundColor = btnBGColor;
    
    btnOk.titleLabel.textColor = btnTxtColor;
    btnCancel.titleLabel.textColor = btnTxtColor;
}

#pragma mark - PopUpView Button Actions
- (void)acceptAction {
    [self hide];
    if ([_hmDelegate respondsToSelector:@selector(popUpView:accepted:inputText:)]) {
        [_hmDelegate popUpView:self accepted:YES inputText:txtField.text];
    }
    
    
}

- (void)cancelAction {
    [self hide];
    if ([_hmDelegate respondsToSelector:@selector(popUpView:accepted:inputText:)]) {
        [_hmDelegate popUpView:self accepted:NO inputText:txtField.text];
    }
    
}

#pragma mark - PopUpView
- (void)showInView:(UIView *)view {
    containerView.alpha = 0;
    containerView.transform = CGAffineTransformMakeScale(0, 0);
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        containerView.alpha = 1.0f;
        containerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    if ([txtField isEditing]) {
        [txtField resignFirstResponder];
    }
    [UIView animateWithDuration:.4
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         containerView.alpha = 0.0;
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}


#pragma mark - TextField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == txtField) {
        if ([UIScreen mainScreen].bounds.size.height < 570) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                containerView.transform = CGAffineTransformMakeTranslation(0, -50);
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == txtField) {
        [txtField resignFirstResponder];
        if ([UIScreen mainScreen].bounds.size.height < 570) {
            if (containerView.frame.origin.y < self.frame.size.height / 2 - (containerView.frame.size.height / 2)) {
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    containerView.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
    }
    return YES;
}
@end
