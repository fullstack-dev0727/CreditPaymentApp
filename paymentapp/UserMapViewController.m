//
//  UserMapViewController.m
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//
@import UIKit;
#import "UserMapViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "JPSThumbnailAnnotation.h"
#import "PaymentViewController.h"

@interface UserMapViewController ()

@end

@implementation UserMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _nearProviders = [[NSMutableArray alloc] init];
    _totalProviders = [[NSMutableArray alloc] init];
    _searchProviders = [[NSMutableArray alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    AppDelegate* appDelegate = APPDELEGATE;
    PFQuery *query = [PFUser query];
    [query whereKey:@"account_category" equalTo:@"1"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            // The find succeeded.
            if ([objects count] > 0) {
                for (int i=0;i<[objects count];i++) {
                    PFUser* item = [objects objectAtIndex:i];
                    CLLocation* location = [[CLLocation alloc] initWithLatitude: [item[@"latitude"] doubleValue] longitude: [item[@"longitude"] doubleValue]];
                    CLLocationDistance distance = [location distanceFromLocation:appDelegate.currentLocation];
                    if (distance < 805)
                        [_nearProviders addObject:item];
                    [_totalProviders addObject:item];
                }
                [self displayProviders];
                
            }
        } else {
            
        }
    }];
    

}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"selpayment"]) {
        PaymentViewController* VC = (PaymentViewController*) segue.destinationViewController;
        VC.providerUser = providerUser;
    }
}
- (void) displayProviders {
    AppDelegate* appDelegate = APPDELEGATE;
    [providerMapView setZoomEnabled:YES];
    [providerMapView addAnnotations:[self annotations]];
    [providerMapView setCenterCoordinate:appDelegate.currentLocation.coordinate animated:YES];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(appDelegate.currentLocation.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [providerMapView regionThatFits:viewRegion];
    [providerMapView setRegion:adjustedRegion animated:YES];
}

- (NSMutableArray *)annotations {
    if (_nearProviders == nil || [_nearProviders count] == 0)
        return nil;
    NSMutableArray * arrray = [[NSMutableArray alloc] init];
    for (int i=0;i<[_nearProviders count]; i++) {
        PFUser* user = [_nearProviders objectAtIndex:i];
        PFFile* photo = user[@"photo"];
        JPSThumbnail *item = [[JPSThumbnail alloc] init];
        item.image = [UIImage imageWithData:photo.getData];
        item.title = @"1";
        item.thumbIndex = i;
        item.subtitle = @"";
        item.coordinate = CLLocationCoordinate2DMake([user[@"latitude"] doubleValue], [user[@"longitude"] doubleValue]);
        item.disclosureBlock = ^{ };
        JPSThumbnailAnnotation* annotationView = [JPSThumbnailAnnotation annotationWithThumbnail:item];
        [arrray addObject: annotationView];
    }
    
    return arrray;
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

- (IBAction)onMenuClick:(id)sender {
    [self.sidePanelController toggleLeftPanel:nil];
}
- (IBAction)onInviteProviderClick:(id)sender {
    
}

- (IBAction)onSearchDidChange:(id)sender {
    UITextField* textField = (UITextField*) sender;
    
    NSString* searchString = textField.text;
    [_searchProviders removeAllObjects];
    if ([textField.text length] > 0) {
        if ([_totalProviders count] > 0) {
            for (int i=0;i<[_totalProviders count]; i++) {
                PFUser* info = [_totalProviders objectAtIndex:i];
                NSString* username = [NSString stringWithFormat:@"%@ %@", info[@"firstname"], info[@"lastname"]];
                NSString* userid = info.username;
                if ([info[@"code"] containsString:searchString] || [[username lowercaseString] containsString:searchString] || [[userid lowercaseString] containsString:searchString]) {
                    [_searchProviders addObject:info];
                }
            }
            
        }
        if ([_searchProviders count] > 0) {
            [resultsView setHidden:false];
        } else {
            [resultsView setHidden:true];
        }
        [searchCollectionView reloadData];
    } else {
        [searchCollectionView reloadData];
        [resultsView setHidden:true];
    }
    
}
#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ( textField == searchTextField )
        [searchTextField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_searchProviders count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"collectionCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView* profileImageView = (UIImageView*) [cell.contentView viewWithTag:300];
    UILabel* codeLabel = (UILabel*) [cell.contentView viewWithTag:301];
    UILabel* usernameLabel = (UILabel*) [cell.contentView viewWithTag:302];
    
    PFUser* user = [_searchProviders objectAtIndex:indexPath.row];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 0;
    PFFile* photo = user[@"photo"];
    [profileImageView setImage:[UIImage imageWithData:photo.getData]];

    [codeLabel setText:user[@"code"]];
    [usernameLabel setText:[NSString stringWithFormat:@"%@ %@", user[@"firstname"], user[@"lastname"]]];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [resultsView setHidden:true];
    [searchTextField setText:@""];
    providerUser = [_searchProviders objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"selpayment" sender:self];
    
}
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (![view.annotation isKindOfClass: [JPSThumbnailAnnotation class]])
        return;
    JPSThumbnailAnnotation *item = (JPSThumbnailAnnotation*) view.annotation;
    providerUser = (PFUser*) [_nearProviders objectAtIndex:item.thumbnail.thumbIndex];
    [self performSegueWithIdentifier:@"selpayment" sender:self];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}

@end
