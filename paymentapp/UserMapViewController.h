//
//  UserMapViewController.h
//  paymentapp
//
//  Created by Petar Vasilev on 1/29/15.
//  Copyright (c) 2015 Petar Vasilev. All rights reserved.
//
@import UIKit;
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface UserMapViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate>{
    
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet MKMapView *providerMapView;
    __weak IBOutlet UIView *resultsView;
    __weak IBOutlet UICollectionView *searchCollectionView;
    PFUser* providerUser;
}
- (IBAction)onMenuClick:(id)sender;
- (IBAction)onInviteProviderClick:(id)sender;
- (IBAction)onSearchDidChange:(id)sender;
- (void) displayProviders;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(NSUInteger)zoom animated:(BOOL)animated;
@property (nonatomic, strong) NSMutableArray* nearProviders;
@property (nonatomic, strong) NSMutableArray* totalProviders;
@property (nonatomic, strong) NSMutableArray* searchProviders;
@end
