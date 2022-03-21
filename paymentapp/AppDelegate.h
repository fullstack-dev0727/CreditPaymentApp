//
//  AppDelegate.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define APPDELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define IS_IOS8  ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
#define IS_IOS7  ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 )
#define CREDITCARD                  @"creditcard"
#define CREDITCARDNUMBER            @"creditcardnumber"
#define CVCNUMBER                   @"cvcnumber"
#define EXPIREDYEAR                 @"expiredyear"
#define EXPIREDMONTH                @"expiredmonth"
#define BANKACCOUNT                 @"bankaccount"
#define ROUTINGNUMBER               @"routingnumber"
#define TWILIO_ACCOUNT_SID          @"AC7df2fd64bc4aab30c73824532559392f"
#define TWILIO_AUTH_TOKEN           @"d4e3a48a54db489defcd1c7c1804fc8c"
#define TWILIO_PHONENUMBER          @"+19292426798"
#define ANDROID_APP_LINK                @"https://itunes.apple.com/us/app/aisight/id943069145?mt=8"
#define IOS_APP_LINK                @"https://itunes.apple.com/us/app/aisight/id943069145?mt=8"
#define SERVER_SMS_URL				@"https://api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages"
#define TESTMODE                    0
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLGeocoder* geocoder;
@property (nonatomic, strong) CLLocation * currentLocation;

- (BOOL) isUserAccount;
- (void) setUserAccounnt:(BOOL)flag;
- (NSString*) getUsername;
- (void) setUsername:(NSString*) name;
- (NSString*) getPassword;
- (void) setPassword:(NSString*) pw;
- (NSString*) getPaymentInfo: (NSString*) key;
- (void) setPaymentInfo:(NSString*) key value : (NSString*) value;
@end

