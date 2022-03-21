//
//  ChooseCreditCardViewController.m
//  paymentapp
//
//  Created by Administrator on 2/6/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "ChooseCreditCardViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
@interface ChooseCreditCardViewController ()

@end
@interface ChooseCreditCardViewController (UIScrollViewDelegate) <UIScrollViewDelegate>
@end
@implementation ChooseCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardMoving:) name:UIKeyboardWillShowNotification object:nil];	// dummyTV
    [defaultCenter addObserver:self selector:@selector(keyboardMoving:) name:UIKeyboardDidShowNotification object:nil];		// dummyTV
    [defaultCenter addObserver:self selector:@selector(keyboardMoving:) name:UIKeyboardWillHideNotification object:nil];	// passwordTextField
    

    
	textScroller.scrollEnabled = NO;
    {
        ccText.text = @"000011112222333344445555";	// need something to get the size
        
        UITextPosition *start	= [ccText beginningOfDocument];
        UITextPosition *end		= [ccText positionFromPosition:start offset:24];
        UITextRange	*range		= [ccText textRangeFromPosition:start toPosition:end];
        CGRect r = [ccText firstRectForRange:range];
        r.size.width /= 24.0f;
        //NSLog(@"First Rect=%@", NSStringFromCGRect(r) );
        ccText.text = @"";
        
        placeView.font = ccText.font;
        //placeView.text = @"∎∎∎∎"; // Unicode not fixed width!!!
        placeView.text = @"XXXX ";
        placeView.showTextOffset = 0;
        placeView.offset = r;
        //placeView.backgroundColor = [UIColor clearColor];
        
        [textScroller insertSubview:placeView atIndex:0];
    }
    type = InvalidCard;
    
//    ccText.inputAccessoryView = containerView;
//    dummyTextView.inputAccessoryView = containerView;
//    [containerView removeFromSuperview];
    
    if(_creditCard) {
        UIView *v = [_creditCard viewForItem];
        [_creditCard resizeView:v]; // shrink width
    } else {
        [dummyTextView becomeFirstResponder];
    }
//    AppDelegate* appDelegate = APPDELEGATE;
//    NSString* creditcard = [appDelegate getPaymentInfo:CREDITCARD];
//    if ([creditcard length] > 0) {
//        [ccText setText:creditcard];
//         placeView.text = @"";
//    }
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

- (IBAction)onSaveButtonClick:(id)sender {
    AppDelegate* appDelegate = APPDELEGATE;
    [appDelegate setPaymentInfo:CREDITCARD value:ccText.text];
    NSLog(@"Number = %@ month=%d year=%d ccv=%d last4=%@", creditCardNum, month, year, ccv,[creditCardNum substringFromIndex: [creditCardNum length] - 4]);

    NSString *monthFix;
    if(month == 1)
    {
        monthFix = @"01";
    }
    else if(month == 2)
    {
        monthFix = @"02";
    }
    else if(month == 3)
    {
        monthFix = @"03";
    }
    else if(month == 4)
    {
        monthFix = @"04";
    }
    else if(month == 5)
    {
        monthFix = @"05";
    }
    else if(month == 6)
    {
        monthFix = @"06";
    }
    else if(month == 7)
    {
        monthFix = @"07";
    }
    else if(month == 8)
    {
        monthFix = @"08";
    }
    else if(month == 9)
    {
        monthFix = @"09";
    }
    else if(month == 10)
    {
        monthFix = @"10";
    }
    else if(month == 11)
    {
        monthFix = @"11";
    }
    else if(month == 12)
    {
        monthFix = @"12";
    }

    [appDelegate setPaymentInfo:CREDITCARDNUMBER value:creditCardNum];
    [appDelegate setPaymentInfo:CVCNUMBER value:[NSString stringWithFormat:@"%d",ccv]];
    [appDelegate setPaymentInfo:EXPIREDYEAR value:[NSString stringWithFormat:@"20%d",year]];
    [appDelegate setPaymentInfo:EXPIREDMONTH value:monthFix];
    [self messageAlert:@"Saved"];
}


- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}

- (void) messageAlert: (NSString*) msg {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notification" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return YES;
    }
    NSString *formattedText;
    BOOL flashForError = NO;
    BOOL updateText = NO;
    BOOL scrollForward = NO;
    BOOL deleting = NO;
    BOOL ret = NO;
    BOOL deletedSpace = NO;
    
    // NSLog(@"RANGE=%@", NSStringFromRange(range) );
    completelyDone = NO;
    if([text length] == 0) {
        updateText = YES;
        deleting = YES;
        if([textView.text length]) {	// handle case of delete when there are no characters left to delete
            unichar c = [textView.text characterAtIndex:range.location];
            if(range.location && range.length == 1 && (c == ' ' || c == '/')) {
                --range.location;
                ++range.length;
                deletedSpace = YES;
            }
        } else {
            return NO;
        }
    }
    
    NSString *newTextOrig = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSUInteger newTextLen = [newTextOrig length];
    
    if(haveFullNumber) {
        if(range.location <= numberLength) {	// <= account for space after last cc digit
            updateText = NO;
            flashForError = NO;
            haveFullNumber = NO;
            goto eND;
        }
        // Test for delete of a space or /
        if(deleting) {
            formattedText = [newTextOrig substringToIndex:range.location];	// handles case of deletion interior to the string
            updateText = YES;
            goto eND;
        }
        
        if(newTextLen > [placeView.text length]) {
            flashForError = YES;
            goto eND;
        }
        
        formattedText = newTextOrig;
        
        NSRange monthRange = [placeView.text rangeOfString:@"MM"];
        if(newTextLen > monthRange.location) {
            if([newTextOrig characterAtIndex:monthRange.location] > '1') {
                // support short cut - we prepend a '0' for them
                formattedText = newTextOrig = [textView.text stringByReplacingCharactersInRange:range withString:[@"0" stringByAppendingString:text]];
                newTextLen = [newTextOrig length];
                NSLog(@"CHANGED IT");
            }
            if(newTextLen >= (monthRange.location + monthRange.length)) {
                month = [[newTextOrig substringWithRange:monthRange] integerValue];
                if(month < 1 || month > 12) {
                    flashForError = YES;
                    goto eND;
                }
            }
        }
        
        NSRange yearRange = [placeView.text rangeOfString:@"YY"];
        if(newTextLen > yearRange.location) {
            NSInteger proposedDecade = ([newTextOrig characterAtIndex:yearRange.location] - '0') * 10;
            NSInteger yearDecade = currentYear - (currentYear % 10);
            // NSLog(@"proposedDecade=%u yearDecade=%u", proposedDecade, yearDecade);
            if(proposedDecade < yearDecade) {
                flashForError = YES;
                goto eND;
            }
            if(newTextLen >= (yearRange.location + yearRange.length)) {
                year = [[newTextOrig substringWithRange:yearRange] integerValue];
                NSInteger diff = year - currentYear;
                if(diff < 0/* || diff > 10*/) {	// blogs on internet suggest some CCs have dates 50 yeras in the future
                    flashForError = YES;
                    goto eND;
                }
                if(creditCardImage != ccBackImage) {
#if __IPHONE_5_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
                    UIViewAnimationOptions transType = type == AMEX ? UIViewAnimationOptionTransitionCrossDissolve : UIViewAnimationOptionTransitionFlipFromBottom;
#else
                    UIViewAnimationOptions transType = type == AMEX ? UIViewAnimationOptionTransitionNone : UIViewAnimationOptionTransitionFlipFromLeft;
#endif
                    [UIView transitionFromView:creditCardImage toView:ccBackImage duration:0.25f options:transType completion:NULL];
                    creditCardImage = ccBackImage;
                }
            }
        }
        
        if(newTextLen == [placeView.text length]) {
            completelyDone = YES;
            NSRange ccvRange = [placeView.text rangeOfString:@"C"]; // first one
            ccvRange.length = type == AMEX ? 4 : 3;
            ccv = [[newTextOrig substringWithRange:ccvRange] integerValue];
        }
        
        updateText = YES;
    } else {
        NSString *newText = [newTextOrig stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSUInteger len = [newText length];
        if(len < CC_LEN_FOR_TYPE) {
            updateText = YES;
            formattedText = newTextOrig;
            // NSLog(@"NEWLEN=%d CC_LEN=%d formattedText=%@", len, CC_LEN_FOR_TYPE, formattedText);
            type = InvalidCard;
        } else {
            type = [CreditCard ccType:newText];
            if(type == InvalidCard) {
                flashForError = YES;
                goto eND;
            }
            if(len == CC_LEN_FOR_TYPE) {
                placeView.text = [CreditCard promptStringForType:type justNumber:YES];
            }
            formattedText = [CreditCard formatForViewing:newText];
            NSUInteger lenForCard = [CreditCard lengthOfStringForType:type];
            
            // NSLog(@"FT=%@ len=%d", formattedText, lenForCard);
            
            if(len < lenForCard) {
                updateText = YES;
            } else
                if(len == lenForCard) {
                    if([CreditCard isValidNumber:newText]) {
                        if([CreditCard isLuhnValid:newText]) {
                            numberLength = [CreditCard lengthOfFormattedStringForType:type];
                            creditCardNum = newText;
                            
                            updateText = YES;
                            scrollForward = YES;
                            haveFullNumber = YES;
                        } else {
                            //flashForError = YES;
                            
                            NSString *oldText = [NSString stringWithString:ccText.text];
                            NSUInteger oldShowOffset = placeView.showTextOffset;
                            
                            //ccText.editable = NO;
                            ccText.text = @"  Recheck Number            ";	// center it (left padding) and push cursor offscreen
                            placeView.showTextOffset = [placeView.text length];
                            warningView.backgroundColor = [UIColor redColor];
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long long)2*NSEC_PER_SEC), dispatch_get_main_queue(), ^
                                           {
                                               ccText.editable = YES;
                                               ccText.text = oldText;
                                               placeView.showTextOffset = oldShowOffset;
                                               warningView.backgroundColor = [UIColor clearColor];
                                           } );
                        }
                    } else {
                        flashForError = YES;
                    }				
                }
        }
        [self updateCCimageWithTransitionTime:0.25f];
    }
eND:
    
    // Order of these blocks important!
    if(scrollForward) {
        [self scrollForward:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long long)250*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ [textScroller flashScrollIndicators]; } );
    }
    if(updateText) {
        NSUInteger textViewLen = [formattedText length];
        NSUInteger formattedLen = [placeView.text length];
        placeView.showTextOffset = MIN(textViewLen, formattedLen);
        
        if((formattedLen > textViewLen) && !deleting) {
            unichar c = [placeView.text characterAtIndex:textViewLen];
            if(c == ' ') formattedText = [formattedText stringByAppendingString:@" "];
            else
                if(c == '/') formattedText = [formattedText stringByAppendingString:@"/"];
        }
        if(!deleting || haveFullNumber || deletedSpace) {
            textView.text = formattedText;
        } else {
            ret = YES; // let textView do it to preserve the cursor location. User updating an incorrect number
        }
        // NSLog(@"formattedText=%@ PLACEVIEW=%@ showTextOffset=%u offset=%@ ret=%d", formattedText, placeView.text, placeView.showTextOffset, NSStringFromCGRect(placeView.offset), ret );
        
    }
    if(flashForError) {
        [self flashScroller];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{ [self updateUI]; });
    //NSLog(@"placeholder=%@ text=%@", placeView.text, ccText.text);
    
    return ret;
}
- (void)updateCCimageWithTransitionTime:(CGFloat)ttime
{
    if(creditCardImage.tag != type) {
        ccImage = [[UIImageView alloc] initWithImage:[CreditCard creditCardImage:type]];
        ccImage.frame = creditCardImage.frame;
        ccImage.tag = type;
        ccBackImage = [[UIImageView alloc] initWithImage:[CreditCard creditCardBackImage:type]];
        ccBackImage.frame = creditCardImage.frame;
        ccBackImage.tag = type;
        // UIViewAnimationOptionTransitionFlipFromLeft UIViewAnimationOptionTransitionFlipFromBottom
        
        [UIView transitionFromView:creditCardImage toView:ccImage duration:ttime options:UIViewAnimationOptionTransitionFlipFromLeft completion:NULL];
        
        //NSLog(@"GOT TO TYPE CHECK old=%d new=%d ccimage=%@ newImage=%@", imageType, type, creditCardImage, ccImage);
        creditCardImage = ccImage;
    }
}
- (void)flashScroller
{
    warningView.backgroundColor = [UIColor redColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long long)250*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{ warningView.backgroundColor = [UIColor clearColor]; } );
}
- (void)updateUI
{
    if(_creditCard) {

    } else {
        BOOL enable = NO;
        if(_creditCard) {
            enable |= month != [[_creditCard month] integerValue];
            enable |= year != [[_creditCard year] integerValue];
        } else {
            enable = completelyDone;
        }
        [saveButton setEnabled:enable];
    }
    //NSLog(@"ADDR_ID=%d completelyDone=%d", self.addressID, completelyDone);
}
- (void)scrollForward:(BOOL)animated
{
    CGFloat width = [self widthToLastGroup];
    
    CGRect frame = ccText.frame;
    frame.size.width = width + textScroller.frame.size.width;
    ccText.frame = frame;
    placeView.frame = frame;
    textScroller.contentSize = CGSizeMake(frame.size.width, textScroller.contentSize.height);
    
    placeView.text = [CreditCard promptStringForType:type justNumber:NO];
    textScroller.scrollEnabled = YES;
    [textScroller setContentOffset:CGPointMake(width, 0) animated:animated];
}
- (CGFloat)widthToLastGroup
{
    NSUInteger oldOffset = placeView.showTextOffset;
    NSUInteger offsetToLastGroup = [CreditCard lengthOfFormattedStringTilLastGroupForType:type];
    placeView.showTextOffset = offsetToLastGroup;
    CGFloat width = [placeView widthToOffset];
    placeView.showTextOffset = oldOffset;
    return width;
}

- (void)keyboardMoving:(NSNotification *)note
{
    NSString *msg			= [note name];
    
    if(!dummyTextView.tag) {
        if([msg isEqualToString:UIKeyboardWillShowNotification]) {
            ;
        } else
            if([msg isEqualToString:UIKeyboardDidShowNotification]) {
                dummyTextView.tag = YES;
                BOOL ret = [ccText becomeFirstResponder];
                assert(ret);
            }
    }
}

@end
