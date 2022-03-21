//
//  SignupProviderViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//

#import "SignupProviderViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "FSNConnection.h"

@interface SignupProviderViewController ()
@property (nonatomic) FSNConnection *connection;
@end

@implementation SignupProviderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 400)];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    if (_user) {
        [profileImageView setImage:_capturedImage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"providertomain"]) {
        MainViewController* VC = (MainViewController*) segue.destinationViewController;
        VC.isUser = NO;
    }
}
#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == whereTextField) {
        [typeTextField becomeFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 400)];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [signupScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 600)];
    svos = signupScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:signupScrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [signupScrollView setContentOffset:pt animated:YES];
    return YES;
}
- (IBAction)onBackClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCodeClick:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"Budgets"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        int index = 10 + [objects count];
        [codeTextField setText:[NSString stringWithFormat:@"%d", index]];
    }];
    
}

- (IBAction)onNextClick:(id)sender {
    if ([whereTextField.text length] == 0) {
        [self messageAlert:@"Please enter location of work"];
        return;
    }
    if ([typeTextField.text length] == 0) {
        [self messageAlert:@"Please enter type of work"];
        return;
    }
    if ([codeTextField.text length] == 0) {
        [self messageAlert:@"Please enter code"];
        return;
    }

    AppDelegate* appDelegate = APPDELEGATE;
    _user[@"location"] = whereTextField.text;
    _user[@"type"] = typeTextField.text;
    _user[@"code"] = codeTextField.text;
    _user[@"latitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.latitude];
    _user[@"longitude"] = [NSString stringWithFormat:@"%f", appDelegate.currentLocation.coordinate.longitude];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery* query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"phone" equalTo:_user[@"phone"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFQuery* query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"email" equalTo:_user[@"email"]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if ([objects count] == 0) {
                    NSData *imageData = UIImagePNGRepresentation(_capturedImage);
                    PFFile *imageFile = [PFFile fileWithName:@"photo.png" data:imageData];
                    
                    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            _user[@"photo"] = imageFile;
                            
                            [_user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                if (!error) {
                                    // Hooerror	NSError *	domain: @"Parse" - code: 202	0x17a5ef00ray! Let them use the app now.
                                    
                                    PFQuery* query = [PFQuery queryWithClassName:@"Transactions"];
                                    [query whereKey:@"phone" equalTo:_user[@"phone"]];
                                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                        int budget = 0;
                                        if (!error) {
                                            if (objects != nil && [objects count] > 0) {
                                                for (int i=0;i<[objects count]; i++) {
                                                    PFObject* object = [objects objectAtIndex:i];
                                                    if ([object[@"provider_id"] length] == 0) {
                                                        budget += [object[@"price"] integerValue];
                                                        object[@"provider_id"] = _user.objectId;
                                                        object[@"provider_name"] = [NSString stringWithFormat:@"%@ %@", _user[@"firstname"], _user[@"lastname"]];
                                                        [object save];
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        PFObject* budgetObject = [PFObject objectWithClassName:@"Budgets"];
                                        budgetObject[@"provider_id"] = _user.objectId;
                                        budgetObject[@"budget"] = @(budget);
                                        [budgetObject save];
                                        
                                        AppDelegate* appDelegate = APPDELEGATE;
                                        [appDelegate setUserAccounnt:FALSE];
                                        [appDelegate setUsername:_user.username];
                                        [appDelegate setPassword:_user.password];
                                        [self performSegueWithIdentifier:@"providertomain" sender:self];
                                    }];

                                } else {
                                    NSString *errorString = [error userInfo][@"error"];
                                    // Show the errorString somewhere and let the user try again.
                                    [self messageAlert: [NSString stringWithFormat:@"Failed to signup. %@", errorString]];
                                }
                            }];
                        } else {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        }
                    }];
                    
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self messageAlert:@"Failed to signup. email already taken"];
                }
            }];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self messageAlert:@"Failed to signup. phone number already taken"];
        }
    }];
}

- (IBAction)onWhereTextChanged:(id)sender {
    if ([whereTextField.text length] > 0) {
        [self.connection cancel];
        self.connection = [self whereConnection];
        [self.connection start];
    } else {
        [whereTableView setHidden:true];
    }
}
#pragma mark - FSConnection Functions
- (FSNConnection *) whereConnection {
    NSString* locationUrl = [NSString stringWithFormat:SERVER_YELP_URL, whereTextField.text];
    NSString *encoded = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (__bridge CFStringRef)(locationUrl), NULL, CFSTR("|"), kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:encoded];
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
                          headers:nil
                       parameters:nil
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
                      _wherePlacemarks = [[result objectForKey:@"response"] objectForKey:@"venues"];
                      if ([_wherePlacemarks count] == 0) {
                          [whereTableView setHidden:true];
                      } else {
                          [whereTableView setHidden:false];
                      }

                      [whereTableView reloadData];
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

#pragma mark - UITableView Delegate & Datasrouce -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_wherePlacemarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"whereTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary* location = _wherePlacemarks[indexPath.row];
    [cell.textLabel setText:location[@"name"]];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView.tag == 50) {
        NSDictionary* location = _wherePlacemarks[indexPath.row];
        [whereTextField setText:location[@"name"]];
    } 
    [tableView setHidden:true];
    
}

- (void) messageAlert: (NSString*) msg {
    HMPopUpView *hmPopUp = [[HMPopUpView alloc] initWithTitle:msg cancelButtonTitle:@"Ok" delegate:nil];
    [hmPopUp showInView:self.view];
}
@end
