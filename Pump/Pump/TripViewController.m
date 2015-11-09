//
//  TripViewController.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripViewController.h"
#import <MapKit/MapKit.h>
#import "TripManager.h"
#import "Utils.h"
#import "SearchUserView.h"
#import "AddPassengersViewController.h"
#import "LoginViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "Database.h"
#import "UserManager.h"
#import "ProfileViewController.h"
#import "PassengerView.h"
#import "ChooseCarViewController.h"
#import "SettingsViewController.h"
#import <BBBadgeBarButtonItem/BBBadgeBarButtonItem.h>
#import "FinishView.h"
#import "DecimalKeypad.h"
#import "TripHistoryViewController.h"
#import <Parse/Parse.h>
#import "NoCarViewController.h"
#import "FinishViewController.h"
#import "PlacesSearchView.h"
#import "CustomMPGViewController.h"

#define BOTTOM_BUTTON_SPACING 15

@implementation TripViewController {
    //MKMapView *_mapView;
    GMSMapView *_mapView;
    UIButton *_myLocationButton;
    UIButton *_moneyButton;
    UIButton * _friendButton;
    UIButton *_directionButton;
    UILabel *_distanceLabel;
    UILabel *_costLabel;
    UIView *_infoBar;
    KLCPopup *_popup;
    UIActivityIndicatorView *_indicator;
    TripHistoryViewController *_historyVC;
    UIButton *_profileButton;
    UIButton *_cancelButton;
    BOOL tracking;
    GMSMarker *_start;
    GMSMarker *_finish;
    FinishView *_finishView;
    NSString *_gasPrice;
    NSMutableDictionary *_avgPrices;
    GMSPolyline *_polyline;
    PlacesSearchView *searchview;
    UIView *_navigationInfoBar;
    UIButton *_moneyCancelButton;
    UILabel *_distanceFromNextLabel;
    UILabel *_instructionLabel;
    UIButton *_directionCancelButton;
    UILabel *_totalDistanceLabel;
    UILabel *_totalTimeLabel;
    UIView *_moneyBar;
    UIImageView * _iconView;
    
}

@synthesize user = _user;

-(void)viewDidLoad {
    [super viewDidLoad];
    [UserManager sharedManager];
    
    [[PFUser currentUser] fetch];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    tracking = YES;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    _profileButton = [[UIButton alloc] init];
    [_profileButton setBackgroundImage:[UIImage imageNamed:@"User Male Filled-25"] forState:UIControlStateNormal];
    [_profileButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_profileButton addTarget:self action:@selector(profileSelected) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _profileButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_cancelButton addTarget:self action:@selector(discardTrip) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"Settings Filled-25"] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(0, 0, 25, 25)];
    [settingsButton addTarget:self action:@selector(settingsSelected) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
    [TripManager sharedManager].delegate = self;
    
    [self setupMapView];
    [self createLowerView];
    [self createSearchView];
    [self createDirectionsBar];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
    [searchview setMapBounds:[[GMSCoordinateBounds alloc] initWithRegion:visibleRegion]];
    [self displaySearchView];
    [self displayLowerButtons];
}

-(void)viewWillLayoutSubviews {
}

-(void)searchView:(PlacesSearchView *)manager didSelectPlace:(GMSAutocompletePrediction *)place {
    [[DirectionsManager sharedManager] startDirectionsToLocationDescription:place.placeID];
    [self displayDirectionButton];
    [self resignFirstResponder];
}

-(void)setUser:(PFUser *)user {
    _user = user;
    [TripManager sharedManager].car = _user;
}

-(void)viewWillAppear:(BOOL)animated {
}
-(void) profileSelected {
    if (!_historyVC) {
        _historyVC = [TripHistoryViewController new];
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_historyVC];
    [nav.navigationBar setBackgroundColor:[Utils defaultColor]];
    [nav.navigationBar setBarTintColor:[Utils defaultColor]];
    [nav.navigationBar setTintColor:[Utils defaultColor]];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    nav.edgesForExtendedLayout = NO;
    [self presentViewController:nav animated:YES completion:^{
    }];
}

-(void) settingsSelected {
    SettingsViewController *settingsVC = [SettingsViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [nav.navigationBar setBackgroundColor:[Utils defaultColor]];
    [nav.navigationBar setBarTintColor:[Utils defaultColor]];
    [nav.navigationBar setTintColor:[Utils defaultColor]];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma TripManagerDelegate

-(void)tripManager:(TripManager *)manager didUpdateStatus:(TripStatusType)status {
    if (status == FINISHED) {
        [self cancelMoney];
    }
}

-(void)tripManager:(TripManager *)manager didUpdateCost:(NSNumber *)cost {
    if ([TripManager sharedManager].status == RUNNING) {
        double c = [cost doubleValue];
        if (c / 10 < 1) {
            [_moneyButton setAttributedTitle:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", c] size:24 color:[UIColor whiteColor]]forState:UIControlStateNormal];
        } else {
            [_moneyButton setAttributedTitle:[Utils defaultString:[NSString stringWithFormat:@"$%.0f", c] size:24 color:[UIColor whiteColor]]forState:UIControlStateNormal];
        }
    }
}

-(void)tripManager:(TripManager *)manager didUpdateStepDistance:(CLLocationDistance)distance totalDistance:(CLLocationDistance)totalDistance totalTime:(NSTimeInterval)totalTime {
    [_distanceFromNextLabel setText:[NSString stringWithFormat:@"%.1fmi", distance/1609.34]];
    [_distanceFromNextLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:30.0f]];
    [_distanceFromNextLabel setTextColor:[UIColor whiteColor]];
    [_distanceFromNextLabel sizeToFit];
    [_distanceFromNextLabel setFrame:CGRectMake(_infoBar.frame.size.width/2 - _distanceFromNextLabel.frame.size.width/2, _infoBar.frame.size.height * .5 - _distanceFromNextLabel.frame.size.height/2, _distanceFromNextLabel.frame.size.width, _distanceFromNextLabel.frame.size.height)];
    
    [_totalTimeLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%.0f min",totalTime/60] size:18 color:[Utils orangeColor]]];
    [_totalTimeLabel sizeToFit];
    [_totalTimeLabel setFrame:CGRectMake(_navigationInfoBar.frame.size.width * .15, _navigationInfoBar.frame.size.height * .4 - _totalTimeLabel.frame.size.height/2, _totalTimeLabel.frame.size.width, _totalTimeLabel.frame.size.height)];
    
    [_totalDistanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%.1fmi",totalDistance/1609.34] size:14 color:[UIColor darkGrayColor]]];
    [_totalDistanceLabel sizeToFit];
    [_totalDistanceLabel setFrame:CGRectMake(_navigationInfoBar.frame.size.width * .15, _totalTimeLabel.frame.origin.y + _totalDistanceLabel.frame.size.height + 5, _totalDistanceLabel.frame.size.width, _totalDistanceLabel.frame.size.height)];
    
    UIImage *manueverImage;
    NSAttributedString *instruction;
    
    if (distance / 1609.34 < 10.0) {
        manueverImage = [[DirectionsManager sharedManager] nextManeuver];
        instruction = [[DirectionsManager sharedManager] nextInstruction];
    } else {
        manueverImage = [[DirectionsManager sharedManager] currentManeuver];
        instruction = [[DirectionsManager sharedManager] currentInstruction];
    }
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString: instruction];
    NSRange range = (NSRange){0,[str length]};
    [str enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont* currentFont = value;
        UIFont *replacementFont = nil;
        if ([currentFont.fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            replacementFont = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14.0f];
        } else {
            replacementFont = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:10.0f];
        }
        [str addAttribute:NSFontAttributeName value:replacementFont range:range];
    }];
    
    [_instructionLabel setAttributedText:str];
    //[_instructionLabel setAttributedText:str];
    [_instructionLabel setTextColor:[UIColor whiteColor]];
    [_instructionLabel sizeToFit];
    [_instructionLabel setFrame:CGRectMake(_infoBar.frame.size.width/2 - _instructionLabel.frame.size.width/2, _infoBar.frame.size.height * .8 - _instructionLabel.frame.size.height/2, _instructionLabel.frame.size.width, _instructionLabel.frame.size.height)];
    
    [_iconView setImage:manueverImage];
    [_iconView sizeToFit];
    [_iconView setFrame:CGRectMake(_infoBar.frame.size.width * .1 - _iconView.frame.size.width/2, _infoBar.frame.size.height * .6 - _iconView.frame.size.height/2, _iconView.frame.size.width, _iconView.frame.size.height)];
}

-(void)tripManager:(TripManager *)manager didUpdateLocation:(CLLocationCoordinate2D)coor direction:(CLLocationDirection)direction {
    if (tracking) {
        if ([DirectionsManager sharedManager].isDirecting) {
            GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:coor zoom:17 bearing:[[DirectionsManager sharedManager] currentDirection] viewingAngle:45];
            
            
            [_mapView animateToCameraPosition:position];
        } else {
            GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:coor zoom:17];
            [_mapView animateToCameraPosition:position];
        }
    }
    
}

-(void)tripManager:(TripManager *)manager didUpdatePath:(GMSPath *)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        _polyline.map = nil;
        _polyline = [GMSPolyline polylineWithPath:path];
        _polyline.strokeColor = [UIColor blueColor];
        _polyline.strokeWidth = 7.f;
        _polyline.map = _mapView;
        if (![DirectionsManager sharedManager].isDirecting) {
            tracking = NO;
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:_polyline.path];
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:self.navigationController.navigationBar.frame.size.height + 40];
            [_mapView animateWithCameraUpdate:update];
        }
    });
}

-(void)didStartDirectingTripManager:(TripManager *)manager {
    [self trackLocation];
}

-(void)tripManager:(TripManager *)manager didUpdateInstructions:(NSAttributedString *)instructions withIcon:(UIImage *)icon {
    [_instructionLabel setAttributedText:instructions];
    [_instructionLabel sizeToFit];
}

#pragma MapView

-(void) setupMapView {
    
    if (_mapView) {
        [_mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        return;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [self.view addSubview: _mapView];
    
    _myLocationButton = [UIButton buttonWithType: UIButtonTypeCustom];
    //[_myLocationButton setBackgroundColor:[Utils defaultColor]];
    [_myLocationButton setFrame:CGRectMake(_mapView.frame.size.width - 60, _mapView.frame.size.height * .3 - 15, 30, 30)];
    [_myLocationButton addTarget:self action:@selector(trackLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [_myLocationButton setBackgroundImage:[UIImage imageNamed:@"Location"] forState:UIControlStateNormal];
    [_myLocationButton.layer setCornerRadius:3];
    [_myLocationButton clipsToBounds];
    if (!tracking) {
        [_mapView addSubview:_myLocationButton];
    }
}

-(void) trackLocation {
    tracking = YES;
    CLLocationCoordinate2D target =
    CLLocationCoordinate2DMake(_mapView.myLocation.coordinate.latitude, _mapView.myLocation.coordinate.longitude);
    
    if ([DirectionsManager sharedManager].isDirecting) {
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:target zoom:17 bearing:[[DirectionsManager sharedManager] currentDirection] viewingAngle:45];
        [_mapView animateToCameraPosition:position];
    } else {
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:target zoom:17];
        [_mapView animateToCameraPosition:position];
    }
    
    
    [_myLocationButton removeFromSuperview];
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    GMSVisibleRegion visibleRegion = mapView.projection.visibleRegion;
    [searchview setMapBounds:[[GMSCoordinateBounds alloc] initWithRegion:visibleRegion]];
    if (gesture) {
        tracking = NO;
        [_mapView addSubview:_myLocationButton];
    }
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    if (!tracking) {
        [_mapView animateToViewingAngle:0];
    }
}

-(void)displaySearchView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    
    if (![DirectionsManager sharedManager].isDirecting) {
        [searchview setFrame:CGRectMake(width * .05, 70, width * .9, height)];
        [searchview setTableHidden:YES];
        if (!searchview.superview) {
            [self.view addSubview:searchview];
            [self.view bringSubviewToFront:searchview];
            [searchview setAlpha:0];
            [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [searchview setAlpha:1];
            } completion:nil];
        }
    } else {
        
    }
}

-(void) displayDirectionButton {
    if (searchview.hasAddress && ![DirectionsManager sharedManager].isDirecting) {
        [_directionButton setFrame:CGRectMake(searchview.frame.origin.x + searchview.frame.size.width - _directionButton.frame.size.width - 10, searchview.frame.origin.y + 50 * .5, _directionButton.frame.size.width, _directionButton.frame.size.height)];
        
        //Animate
        if (!_directionButton.superview) {
            [self.view addSubview:_directionButton];
            [_directionButton setAlpha:0];
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_directionButton setAlpha:1];
            } completion:nil];
        }
    }
}

-(void)createSearchView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    searchview = [[PlacesSearchView alloc] initWithFrame:CGRectMake(width * .05, 70, width * .9, height)];
    [searchview.layer setShadowColor:[UIColor blackColor].CGColor];
    [searchview.layer setShadowRadius:4];
    [searchview.layer setShadowOffset:CGSizeMake(2, 2)];
    [searchview.layer setShadowOpacity:.5];
    searchview.layer.masksToBounds = NO;
    [searchview.layer setBorderWidth:0];
    [searchview.layer setBorderColor:[UIColor clearColor].CGColor];
    searchview.delegate = self;
}

-(void)displayLowerButtons {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    
    if ([TripManager sharedManager].status != RUNNING) {
        
        //Set Frames
        if (!_moneyButton.superview) {
            [_moneyButton setFrame:CGRectMake(width - _moneyButton.frame.size.width - BOTTOM_BUTTON_SPACING, height - _moneyButton.frame.size.height - BOTTOM_BUTTON_SPACING, _moneyButton.frame.size.width, _moneyButton.frame.size.height)];
        }
        
        [_friendButton setFrame:CGRectMake(_moneyButton.frame.origin.x - _friendButton.frame.size.width - BOTTOM_BUTTON_SPACING, height - _friendButton.frame.size.height - BOTTOM_BUTTON_SPACING, _friendButton.frame.size.width, _friendButton.frame.size.height)];
        
        //Animate
        if (!_moneyButton.superview) {
            [self.view addSubview:_moneyButton];
            [_moneyButton setAlpha:0];
            [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_moneyButton setAlpha:1];
            } completion:nil];
        }
    
        if (!_friendButton.superview) {
            [self.view addSubview:_friendButton];
            [_friendButton setAlpha:0];
            [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [_friendButton setAlpha:1];
            } completion:nil];
        }
    }
}

-(void) createDirectionsBar {
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * .166)];
    [_infoBar.layer setShadowColor:[UIColor blackColor].CGColor];
    [_infoBar.layer setShadowRadius:2];
    [_infoBar.layer setShadowOffset:CGSizeMake(-2, -2)];
    [_infoBar.layer setShadowOpacity:.5];
    _infoBar.layer.masksToBounds = NO;
    [_infoBar setBackgroundColor:[Utils defaultColor]];
    
    _distanceFromNextLabel = [[UILabel alloc] init];
    [_distanceFromNextLabel setAttributedText:[Utils defaultString:@" " size:34 color:[UIColor whiteColor]]];
    [_distanceFromNextLabel sizeToFit];
    [_distanceFromNextLabel setFrame:CGRectMake(_infoBar.frame.size.width/2 - _distanceFromNextLabel.frame.size.width/2, _infoBar.frame.size.height * .5 - _distanceFromNextLabel.frame.size.height/2, _distanceFromNextLabel.frame.size.width, _distanceFromNextLabel.frame.size.height)];
    [_infoBar addSubview:_distanceFromNextLabel];
    
    _instructionLabel = [[UILabel alloc] init];
    [_instructionLabel setAttributedText:[Utils defaultString:@" " size:18 color:[UIColor whiteColor]]];
    [_instructionLabel sizeToFit];
    [_instructionLabel setFrame:CGRectMake(_infoBar.frame.size.width/2 - _instructionLabel.frame.size.width/2, _infoBar.frame.size.height * .8 - _instructionLabel.frame.size.height/2, _instructionLabel.frame.size.width, _instructionLabel.frame.size.height)];
    [_infoBar addSubview:_instructionLabel];
    
    _iconView = [UIImageView new];
    [_infoBar addSubview:_iconView];
}

-(void) displayDirectionBar {
    if (!_infoBar.superview) {
        [self.view addSubview:_infoBar];
        [self.view sendSubviewToBack:_infoBar];
        [self.view sendSubviewToBack:_mapView];
        [_infoBar setFrame:CGRectMake(_infoBar.frame.origin.x, - _infoBar.frame.size.height, _infoBar.frame.size.width, _infoBar.frame.size.height)];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_infoBar setFrame:CGRectMake(_infoBar.frame.origin.x, 0, _infoBar.frame.size.width, _infoBar.frame.size.height)];
        } completion:^(BOOL finished) {
        }];
    }
}

-(void) createLowerView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    
    _moneyButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_moneyButton setBackgroundColor:[Utils greenColor]];
    [_moneyButton setAlpha:1];
    [_moneyButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_moneyButton.layer setShadowRadius:1];
    [_moneyButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [_moneyButton.layer setShadowOpacity:.5];
    _moneyButton.layer.masksToBounds = NO;
    [_moneyButton setFrame:CGRectMake(0, 0, 50, 50)];
    NSAttributedString *title = [Utils defaultString:@"$" size:28 color:[UIColor whiteColor]];
    [_moneyButton setAttributedTitle: title forState:UIControlStateNormal];
    [_moneyButton addTarget:self action:@selector(trackMoney) forControlEvents:UIControlEventTouchUpInside];
    [_moneyButton.layer setCornerRadius:25];
    [_moneyButton clipsToBounds];
    
    _moneyCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_moneyCancelButton setBackgroundColor:[UIColor clearColor]];
    [_moneyCancelButton setAlpha:1];
    [_moneyCancelButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_moneyCancelButton.layer setShadowRadius:1];
    [_moneyCancelButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [_moneyCancelButton.layer setShadowOpacity:.5];
    _moneyCancelButton.layer.masksToBounds = NO;
    [_moneyCancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_moneyCancelButton setImage:[UIImage imageNamed:@"green_cancel"] forState:UIControlStateNormal];
    [_moneyCancelButton addTarget:self action:@selector(cancelMoney) forControlEvents:UIControlEventTouchUpInside];
    [_moneyCancelButton.layer setCornerRadius:25];
    [_moneyCancelButton clipsToBounds];
    
//    _friendButton = [UIButton buttonWithType: UIButtonTypeCustom];
//    [_friendButton setBackgroundColor:[Utils redColor]];
//    [_friendButton setAlpha:1];
//    [_friendButton setFrame:CGRectMake(0, 0, 50, 50)];
//    [_friendButton.layer setShadowOffset:CGSizeMake(1, 1)];
//    [_friendButton.layer setShadowColor:[UIColor blackColor].CGColor];
//    [_friendButton.layer setShadowRadius:1];
//    [_friendButton.layer setShadowOpacity:.5];
//    _friendButton.layer.masksToBounds = NO;
//    [_friendButton setImage:[UIImage imageNamed:@"borrow_icon"] forState:UIControlStateNormal];
//    [_friendButton addTarget:self action:@selector(selectFriend) forControlEvents:UIControlEventTouchUpInside];
//    [_friendButton.layer setCornerRadius:25];
//    [_friendButton clipsToBounds];
    
    _directionButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_directionButton setBackgroundColor:[Utils orangeColor]];
    [_directionButton setAlpha:1];
    [_directionButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_directionButton.layer setShadowRadius:1];
    [_directionButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [_directionButton.layer setShadowOpacity:.5];
    _directionButton.layer.masksToBounds = NO;
    [_directionButton setImage:[UIImage imageNamed:@"car_icon"] forState:UIControlStateNormal];
    [_directionButton setFrame:CGRectMake(0, 0, 50, 50)];
    [_directionButton addTarget:self action:@selector(startDirections) forControlEvents:UIControlEventTouchUpInside];
    [_directionButton.layer setCornerRadius:25];
    [_directionButton clipsToBounds];
    
    _navigationInfoBar = [[UIView alloc] initWithFrame:CGRectMake(0, height - _moneyButton.frame.size.height - BOTTOM_BUTTON_SPACING*2, width, _moneyButton.frame.size.height + BOTTOM_BUTTON_SPACING * 2)];
    [_navigationInfoBar.layer setShadowColor:[UIColor blackColor].CGColor];
    [_navigationInfoBar.layer setShadowRadius:1];
    [_navigationInfoBar.layer setShadowOffset:CGSizeMake(1, 1)];
    [_navigationInfoBar.layer setShadowOpacity:.5];
    _navigationInfoBar.layer.masksToBounds = NO;
    [_navigationInfoBar setBackgroundColor:[UIColor whiteColor]];
    
    _totalTimeLabel = [[UILabel alloc] init];
    [_totalTimeLabel setAttributedText:[Utils defaultString:@"1 hr 31 min" size:18 color:[Utils orangeColor]]];
    [_totalTimeLabel sizeToFit];
    [_totalTimeLabel setFrame:CGRectMake(_navigationInfoBar.frame.size.width * .15, _navigationInfoBar.frame.size.height * .4 - _totalTimeLabel.frame.size.height/2, _totalTimeLabel.frame.size.width, _totalTimeLabel.frame.size.height)];
    [_navigationInfoBar addSubview:_totalTimeLabel];
    
    _totalDistanceLabel = [[UILabel alloc] init];
    [_totalDistanceLabel setAttributedText:[Utils defaultString:@"64.6mi" size:14 color:[UIColor darkGrayColor]]];
    [_totalDistanceLabel sizeToFit];
    [_totalDistanceLabel setFrame:CGRectMake(_navigationInfoBar.frame.size.width * .15, _totalTimeLabel.frame.origin.y + _totalDistanceLabel.frame.size.height + 5, _totalDistanceLabel.frame.size.width, _totalDistanceLabel.frame.size.height)];
    [_navigationInfoBar addSubview:_totalDistanceLabel];
    
    _directionCancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_directionCancelButton setBackgroundColor:[UIColor clearColor]];
    [_directionCancelButton setAlpha:1];
    [_directionCancelButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [_directionCancelButton.layer setShadowRadius:1];
    [_directionCancelButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [_directionCancelButton.layer setShadowOpacity:.5];
    _directionCancelButton.layer.masksToBounds = NO;
    [_directionCancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_directionCancelButton setImage:[UIImage imageNamed:@"orange_cancel"] forState:UIControlStateNormal];
    [_directionCancelButton addTarget:self action:@selector(cancelDirections) forControlEvents:UIControlEventTouchUpInside];
    [_directionCancelButton.layer setCornerRadius:25];
    [_directionCancelButton clipsToBounds];
    [_directionCancelButton setFrame:CGRectMake(BOTTOM_BUTTON_SPACING, _navigationInfoBar.frame.size.height * .5 - _directionCancelButton.frame.size.width * .5, _moneyCancelButton.frame.size.width, _directionCancelButton.frame.size.height)];
    [_navigationInfoBar addSubview:_directionCancelButton];
    
}

-(void) removeDirectionsButton {
    if (_directionButton.superview) {
        _directionButton.alpha = 1;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_directionButton setAlpha:0];
        } completion:^(BOOL finished) {
            [_directionButton removeFromSuperview];
        }];
    }
}

-(void) removeSearchView {
    if (searchview.superview) {
        searchview.alpha = 1;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [searchview setAlpha:0];
        } completion:^(BOOL finished) {
            [searchview removeFromSuperview];
        }];
    }
}

-(void) displayBottomInfoBar {
    //if (!_navigationInfoBar.superview) {
        [self.view addSubview:_navigationInfoBar];
        [self.view sendSubviewToBack:_navigationInfoBar];
        [self.view sendSubviewToBack:_mapView];
        [_navigationInfoBar setFrame:CGRectMake(_navigationInfoBar.frame.origin.x, self.view.frame.size.height + _navigationInfoBar.frame.size.height, _navigationInfoBar.frame.size.width, _navigationInfoBar.frame.size.height)];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_navigationInfoBar setFrame:CGRectMake(_navigationInfoBar.frame.origin.x, self.view.frame.size.height - _navigationInfoBar.frame.size.height, _navigationInfoBar.frame.size.width, _navigationInfoBar.frame.size.height)];
        } completion:^(BOOL finished) {
        }];
    //}

}

-(void) removeBottomInfoBar {
    if (_navigationInfoBar.superview) {
//        [_navigationInfoBar setFrame:CGRectMake(_navigationInfoBar.frame.origin.x, _navigationInfoBar.frame.origin.y - _navigationInfoBar.frame.size.height, _navigationInfoBar.frame.size.width, _navigationInfoBar.frame.size.height)];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_navigationInfoBar setFrame:CGRectMake(_navigationInfoBar.frame.origin.x, self.view.frame.size.height + _navigationInfoBar.frame.size.height, _navigationInfoBar.frame.size.width, _navigationInfoBar.frame.size.height)];
        } completion:^(BOOL finished) {
            [_navigationInfoBar removeFromSuperview];
        }];
    }
}

-(void) switchToDirectionsBar {
    CGRect frame = self.navigationController.navigationBar.frame;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.navigationController.navigationBar setFrame:CGRectMake(frame.origin.x, - frame.size.height, frame.size.width, frame.size.height)];
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:YES];
    }];
    [self displayDirectionBar];
}

-(void) removeDirectionBar {
    if (_infoBar.superview) {
        [_infoBar setFrame:CGRectMake(_infoBar.frame.origin.x, 0, _infoBar.frame.size.width, _infoBar.frame.size.height)];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_infoBar setFrame:CGRectMake(_infoBar.frame.origin.x, - _infoBar.frame.size.height, _infoBar.frame.size.width, _infoBar.frame.size.height)];
        } completion:^(BOOL finished) {
            [_infoBar removeFromSuperview];
        }];
    }
}

-(void) switchToNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
     CGRect frame = self.navigationController.navigationBar.frame;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.navigationController.navigationBar setFrame:CGRectMake(frame.origin.x, 20, frame.size.width, frame.size.height)];
    } completion:^(BOOL finished) {
    }];
    [self removeDirectionBar];
}

-(void) startDirections {
    [self displayBottomInfoBar];
    [self removeSearchView];
    [self removeDirectionsButton];
    [self switchToDirectionsBar];
    [[DirectionsManager sharedManager] startDirecting];
    [self trackLocation];
}

-(void) cancelDirections {
    [DirectionsManager sharedManager].isDirecting = NO;
    [self switchToNavigationBar];
    [self removeBottomInfoBar];
    [self displaySearchView];
    [[DirectionsManager sharedManager] endDirecting];
    [self trackLocation];
}

-(void)trackMoney {
    [[DirectionsManager sharedManager] nextStep];
    if(![TripManager sharedManager].mpg) {
        CustomMPGViewController *vc = [CustomMPGViewController new];
        [self presentViewController:vc animated:YES completion:nil];
    }
    if ([TripManager sharedManager].status != RUNNING) {
        [[TripManager sharedManager] setStatus:RUNNING];
        CGRect frame = _moneyButton.frame;
        
        [_moneyCancelButton setFrame:CGRectMake(self.view.frame.size.width - _moneyCancelButton.frame.size.width - BOTTOM_BUTTON_SPACING, frame.origin.y + frame.size.height * .5 - _moneyCancelButton.frame.size.width * .5, _moneyCancelButton.frame.size.width, _moneyCancelButton.frame.size.height)];
        [self.view addSubview:_moneyCancelButton];
        
        [self.view bringSubviewToFront:_moneyButton];
        [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_moneyButton setFrame:CGRectMake(frame.origin.x - frame.size.width - BOTTOM_BUTTON_SPACING * 2, frame.origin.y, frame.size.width, frame.size.height)];
            [_moneyButton.titleLabel setAlpha:0];
            
            [_moneyCancelButton setFrame:CGRectMake(_moneyCancelButton.frame.origin.x - frame.size.width, frame.origin.y + frame.size.height * .5 - _moneyCancelButton.frame.size.width * .5, _moneyCancelButton.frame.size.width, _moneyCancelButton.frame.size.height)];
            [_moneyCancelButton setAlpha:1];
            
        } completion:^(BOOL finished) {}];
        frame = _moneyButton.frame;
        [_moneyButton setAttributedTitle:[Utils defaultString:@"$0.00" size:24 color:[UIColor whiteColor]]forState:UIControlStateNormal];
        [UIView animateWithDuration:.2 delay:.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_moneyButton.titleLabel setAlpha:1];
            [_moneyButton setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width * 2, frame.size.height)];
            
            [_moneyCancelButton setFrame:CGRectMake(_moneyCancelButton.frame.origin.x + frame.size.width, frame.origin.y + frame.size.height * .5 - _moneyCancelButton.frame.size.width * .5, _moneyCancelButton.frame.size.width, _moneyCancelButton.frame.size.height)];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        AddPassengersViewController *vc = [AddPassengersViewController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:^{
        }];
    }
}

-(void) cancelMoney {
    if ([TripManager sharedManager].status != PENDING) {
        [[TripManager sharedManager] setStatus:PENDING];
        CGRect frame = _moneyButton.frame;
        
        [self.view bringSubviewToFront:_moneyButton];
        
        [UIView animateWithDuration:.2 delay:.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_moneyButton.titleLabel setAlpha:0];
            [_moneyButton setFrame:CGRectMake(frame.origin.x, frame.origin.y, 50, frame.size.height)];
        } completion:^(BOOL finished) {
            
        }];
        
        [_moneyButton setAttributedTitle:[Utils defaultString:@"$" size:24 color:[UIColor whiteColor]]forState:UIControlStateNormal];
        
        frame = _moneyButton.frame;
        
        [self.view addSubview:_friendButton];
        [self.view bringSubviewToFront:_moneyButton];
        [_friendButton setAlpha:0];
        [UIView animateWithDuration:.2 delay:.15 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_moneyButton setFrame:CGRectMake(frame.origin.x + frame.size.width + BOTTOM_BUTTON_SPACING * 2, frame.origin.y, frame.size.width, frame.size.height)];
            [_moneyButton.titleLabel setAlpha:1];
            
            [_moneyCancelButton setAlpha:0];
            
            [_friendButton setAlpha:1];
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void) selectFriend {
    
}


- (void) discardTrip {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Quit trip" message:@"This trip will not be saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
    alert.tag = 0;
    alert.delegate = self;
    [alert show];
    _finishView = nil;
}


@end
