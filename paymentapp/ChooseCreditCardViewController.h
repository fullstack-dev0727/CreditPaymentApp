//
//  ChooseCreditCardViewController.h
//  paymentapp
//
//  Created by Administrator on 2/6/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UIMonthYearPicker.h"
#import "GradientScrollView.h"
#import "PlaceHolderTextView.h"
#import "CreditCard.h"
@interface ChooseCreditCardViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>{
    
    __weak IBOutlet UIButton *menuButton;
    
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UIImageView *creditCardImage;
    __weak IBOutlet GradientScrollView *textScroller;
    __weak IBOutlet UIView *warningView;
    __weak IBOutlet PlaceHolderTextView *placeView;
    __weak IBOutlet UITextView *ccText;
    
    __weak IBOutlet UITextView *dummyTextView;
    __weak IBOutlet UIView *containerView;
    UIImageView *ccImage;
    UIImageView *ccBackImage;
    
    CGFloat oldX;
    NSInteger currentYear;
    
    // CreditCard Info
    creditCardType type;		// brand
    NSUInteger numberLength;	// length of formatted number only
    NSString *creditCardNum;	// real number not the formatted one
    NSInteger month;			// two digits
    NSInteger year;				// two digits
    NSInteger ccv;				// three or 4 digits
    
    // States
    BOOL haveFullNumber;		// got a full number
    BOOL completelyDone;
    
    NSString *successMsg;
}
@property (nonatomic, strong) CreditCard *creditCard;
- (IBAction)onSaveButtonClick:(id)sender;
- (IBAction)onMenuClick:(id)sender;
@end
