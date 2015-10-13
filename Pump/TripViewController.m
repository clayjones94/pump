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


@implementation TripViewController {
    //MKMapView *_mapView;
    GMSMapView *_mapView;
    UIButton *_myLocationButton;
    UIButton *_mpgButton;
    UIButton *_startButton;
    UIButton * _finishButton;
    UIButton *_pauseButton;
    UILabel *_distanceLabel;
    UILabel *_costLabel;
    UIView *_infoBar;
    KLCPopup *_popup;
    UITextField *_mpgField;
    UIButton *_gasPriceButton;
    UITextField *_gasPriceField;
    UIButton *_carButton;
    UIActivityIndicatorView *_indicator;
    ProfileViewController *_profileVC;
    UIButton *_profileButton;
    UIButton *_cancelButton;
    BOOL tracking;
    UITextView *_descriptionField;
    GMSMarker *_start;
    GMSMarker *_finish;
    FinishView *_finishView;
    NSString *_gasPrice;
}

-(void)viewDidLoad {
    [TripManager sharedManager].delegate = self;
    [UserManager sharedManager];
    
    tracking = YES;
    
    _profileButton = [[UIButton alloc] init];
    [_profileButton setBackgroundImage:[UIImage imageNamed:@"User Male Filled-25"] forState:UIControlStateNormal];
    [_profileButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_profileButton addTarget:self action:@selector(profileSelected) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _profileButton];
    
    UIButton *settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"Settings Filled-25"] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(0, 0, 25, 25)];
    [settingsButton addTarget:self action:@selector(settingsSelected) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_cancelButton addTarget:self action:@selector(discardTrip) forControlEvents:UIControlEventTouchUpInside];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTrip) name:@"Show Popup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPassengers) name:@"Add Passengers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCar) name:@"Choose Car" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTrip) name:@"Select Car" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPendingsFromNotification:) name:@"Open from Notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTrips) name:@"Save Trip" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:_popup selector:@selector(dismiss:) name:@"Discard Trip" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotificationCount) name:@"Recieve Notification" object:nil];
    
    [self setupMapView];
    [self setupPendingView];
    [self setupRunningView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id userID = [defaults objectForKey:PUMP_USER_ID_KEY];
    if ((![[Venmo sharedInstance] isSessionValid] || !userID) && ![[UserManager sharedManager] notUsingVenmo] ) {
        LoginViewController *loginvc = [LoginViewController new];
        [self presentViewController:loginvc animated:YES completion:nil];
        _descriptionField = nil;
        _profileVC = nil;
    }
//    [self refreshNotificationCount];
}

//-(void) refreshNotificationCount {
//    
//    BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:_profileButton];
//    barButton.shouldHideBadgeAtZero = YES;
//    barButton.badgeOriginX = 15;
//    [barButton setBadgeMinSize:0];
//    // Set a value for the badge
//    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
//        barButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
//        self.navigationItem.leftBarButtonItem = barButton;
//    } else {
//        barButton.badgeValue = @"0";
//        [self.navigationItem setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithCustomView: _profileButton]];
//    }
//}

-(void) profileSelected {
    if (!_profileVC) {
        _profileVC = [ProfileViewController new];
        [_profileVC refresh];
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_profileVC];
    [nav.navigationBar setBackgroundColor:[Utils defaultColor]];
    [nav.navigationBar setBarTintColor:[Utils defaultColor]];
    [nav.navigationBar setTintColor:[Utils defaultColor]];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self presentViewController:nav animated:YES completion:^{
    }];
}

-(void) openPendingsFromNotification: (BOOL) isRequests {
    if (isRequests) {
        [_profileVC.segmentedControl setSelectedSegmentIndex:0];
    } else {
        [_profileVC.segmentedControl setSelectedSegmentIndex:1];
    }
    if (_profileVC) {
        [_profileVC refresh];
    }
    [self profileSelected];
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
    if(status == RUNNING) {
        [_startButton removeFromSuperview];
        [_mapView addSubview:_infoBar];
        [_mapView addSubview:_pauseButton];
        [self updateInfoBar];
        [_pauseButton setAttributedTitle:[Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _cancelButton];
    }  else if (status == PAUSED) {
        [_pauseButton setAttributedTitle:[Utils defaultString:@"Resume Trip" size:17 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    } else if (status == FINISHED){
        [self.navigationController setNavigationBarHidden:YES];
        [_pauseButton removeFromSuperview];
        [_finishButton removeFromSuperview];
        [_infoBar removeFromSuperview];
        GMSPolyline *polyline = [TripManager sharedManager].polyline;
        GMSPath * path = polyline.path;
        tracking = NO;
        [TripManager sharedManager].polyline.map = _mapView;
        if (_start) {
            _start.map = nil;
            _start = nil;
        }
        if (_finish) {
            _finish.map = nil;
            _finish = nil;
        }
        _start = [GMSMarker markerWithPosition:[path coordinateAtIndex:0]];
        _finish = [GMSMarker markerWithPosition:[path coordinateAtIndex:path.count - 1]];
        [_start setIcon:[GMSMarker markerImageWithColor:[UIColor greenColor]]];
        [_finish setIcon:[GMSMarker markerImageWithColor:[UIColor redColor]]];
        _start.map = _mapView;
        _finish.map = _mapView;
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:66];
        [_mapView animateWithCameraUpdate:update];
    } else if (status == PENDING){
        [self.navigationController setNavigationBarHidden:NO];
        if (_start || _start.map) {
            _start.map = nil;
            _start = nil;
        }
        if (_finish || _finish.map) {
            _finish.map = nil;
            _finish = nil;
        }
        [TripManager sharedManager].polyline.map = nil;
        [self trackLocation];
        [KLCPopup dismissAllPopups];
        [self setupPendingView];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _profileButton];
    }
}

-(void)tripManager:(TripManager *)manager didUpdateLocationWith:(CLLocationDistance)distance and:(GMSPolyline *)polyline {
    polyline.map = _mapView;
    if (!_start || !_start.map) {
        if (_start) {
            _start.map = nil;
        }
        _start = [GMSMarker markerWithPosition:[polyline.path coordinateAtIndex:0]];
        [_start setIcon:[GMSMarker markerImageWithColor:[UIColor greenColor]]];
        _start.map = _mapView;
    }
    [_mapView setNeedsDisplay];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.1f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[Utils defaultColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(_infoBar.frame.size.width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[TripManager sharedManager].gasPrice doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[Utils defaultColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
        [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[Utils defaultColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
}

-(void)tripManager:(TripManager *)manager didUpdateLocation:(CLLocationCoordinate2D)coor direction:(CLLocationDirection)direction {
    if (tracking) {
//        CGFloat angle;
//        if ([TripManager sharedManager].status == RUNNING || [TripManager sharedManager].status == PAUSED) {
//            angle = 45;
//        } else {
//            direction = 0;
//            angle = 0;
//        }
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:coor zoom:17];
        [_mapView animateToCameraPosition:position];
    }
    
}

#pragma MapView

-(void) setupMapView {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:6];

    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [self.view addSubview: _mapView];
    
    _myLocationButton = [UIButton buttonWithType: UIButtonTypeCustom];
    //[_myLocationButton setBackgroundColor:[Utils defaultColor]];
    [_myLocationButton setFrame:CGRectMake(_mapView.frame.size.width - 40, _mapView.frame.size.height * .95 - 15, 30, 30)];
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
    
//    CLLocationDirection direction;
//    CGFloat angle;
//    if ([TripManager sharedManager].status == RUNNING || [TripManager sharedManager].status == PAUSED) {
//        direction = [TripManager sharedManager].direction;
//        angle = 45;
//    } else {
//        direction = 0;
//        angle = 0;
//    }
    
    GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:target zoom:17]; //bearing:direction viewingAngle:angle];
    
    
    [_mapView animateToCameraPosition:position];
    [_myLocationButton removeFromSuperview];
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
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

-(void) setupPendingView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _startButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_startButton setBackgroundColor:[Utils defaultLightColor]];
    [_startButton setAlpha:.9];
    [_startButton setFrame:CGRectMake(width * 1/2 - 75, height * .95 - 15, 150, 30)];
    [_startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"Start Trip" size:17 color:[UIColor whiteColor]];
    [_startButton setAttributedTitle: title forState:UIControlStateNormal];
    [_startButton.layer setCornerRadius:15];
    [_startButton clipsToBounds];
    [_mapView addSubview:_startButton];
}


-(void) updateInfoBar {
    CGFloat width = self.view.frame.size.width;
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[Utils defaultColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[Utils defaultColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
            [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[Utils defaultColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    
    NSNumber *mpg = [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"];
    if ([mpg doubleValue] == 0) {
        [self changeMPG];
    } else {
        [[TripManager sharedManager] setMpg:mpg];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[UIColor whiteColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor whiteColor]]];
        [_mpgButton setAttributedTitle:title forState:UIControlStateNormal];
    }

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[UIColor whiteColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor whiteColor]]];
    [_gasPriceButton setAttributedTitle:title forState:UIControlStateNormal];
    
//    if (![TripManager sharedManager].car) {
//        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:16 color:[UIColor lightGrayColor]]];
//        [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//        [_carButton setAttributedTitle:title forState:UIControlStateNormal];
//    } else {
//        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
//        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
//        [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
//        [_carButton setAttributedTitle:title forState:UIControlStateNormal];
//    }
}

-(void) setupRunningView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, height * .27)];
    [_infoBar setBackgroundColor:[UIColor whiteColor]];
    [_infoBar setAlpha:.8];
    
    _mpgButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
//    [_mpgButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [_mpgButton.layer setBorderWidth:1];
    [_mpgButton setBackgroundColor:[Utils mpgColor]];
    [_mpgButton addTarget:self action:@selector(changeMPG) forControlEvents:UIControlEventTouchUpInside];
    _mpgButton.titleLabel.numberOfLines = 2;
    _mpgButton.titleLabel.textAlignment = NSTextAlignmentCenter;

    [_mpgButton.layer setCornerRadius:3];
    NSNumber *mpg = [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"];
    if (!mpg) {
        mpg = @0;
    }
    [[TripManager sharedManager] setMpg:mpg];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[Utils defaultColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor lightGrayColor]]];
    [_mpgButton setAttributedTitle:title forState:UIControlStateNormal];
    [_mpgButton setFrame:CGRectMake(width/4 - (width * .35)/2, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .18, width * .35, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_mpgButton];
    
    _gasPriceButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
//    [_gasPriceButton.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [_gasPriceButton.layer setBorderWidth:1];
    [_gasPriceButton setBackgroundColor:[Utils gasColor]];
    [_gasPriceButton.layer setCornerRadius:3];
    _gasPriceButton.titleLabel.numberOfLines = 2;
    _gasPriceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_gasPriceButton addTarget:self action:@selector(changeGasPrice) forControlEvents:UIControlEventTouchUpInside];
    NSNumber *gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
    if (!gasPrice) {
        gasPrice = @0;
    }
    [[TripManager sharedManager] setGasPrice:gasPrice];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[UIColor whiteColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor whiteColor]]];
    [_gasPriceButton setAttributedTitle:title forState:UIControlStateNormal];
    [_gasPriceButton setFrame:CGRectMake(width * 3/4 - (width * .35)/2, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .18, width * .35, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_gasPriceButton];
    

//    _carButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
//    [_carButton.layer setBorderWidth:1];
//    [_carButton.layer setCornerRadius:3];
//    _carButton.titleLabel.numberOfLines = 2;
//    _carButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_carButton addTarget:self action:@selector(changeCar) forControlEvents:UIControlEventTouchUpInside];
//    if (![TripManager sharedManager].car) {
//        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:16 color:[UIColor lightGrayColor]]];
//            [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    } else {
//        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
//        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
//            [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
//    }
//    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
//    [_carButton setFrame:CGRectMake(width * .675, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
//    [_infoBar addSubview:_carButton];
    
    UIColor *freeLabelColor = [Utils defaultColor];
    
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:freeLabelColor]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    [_infoBar addSubview:_distanceLabel];
    
    UILabel *distanceDetailLabel = [[UILabel alloc] init];
    [distanceDetailLabel setAttributedText:[Utils defaultString:@"Distance" size:12 color:freeLabelColor]];
    [distanceDetailLabel sizeToFit];
    [distanceDetailLabel setFrame:CGRectMake(width * 1/4 - distanceDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y - distanceDetailLabel.frame.size.height + 3, distanceDetailLabel.frame.size.width, distanceDetailLabel.frame.size.height)];
    [_infoBar addSubview:distanceDetailLabel];
    
    UILabel *unitDetailLabel = [[UILabel alloc] init];
    [unitDetailLabel setAttributedText:[Utils defaultString:@"miles" size:10 color:freeLabelColor]];
    [unitDetailLabel sizeToFit];
    [unitDetailLabel setFrame:CGRectMake(width * 1/4 - unitDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y + _distanceLabel.frame.size.height - 6, unitDetailLabel.frame.size.width, unitDetailLabel.frame.size.height)];
    [_infoBar addSubview:unitDetailLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_infoBar.frame.size.width/2, _infoBar.frame.size.height * .65, 1, _infoBar.frame.size.height * .2)];
    lineView.backgroundColor = freeLabelColor;
    [_infoBar addSubview:lineView];
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:freeLabelColor]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    [_infoBar addSubview:_costLabel];
    
    UILabel *costDetailLabel = [[UILabel alloc] init];
    [costDetailLabel setAttributedText:[Utils defaultString:@"Cost" size:12 color:freeLabelColor]];
    [costDetailLabel sizeToFit];
    [costDetailLabel setFrame:CGRectMake(width * 3/4 - costDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - costDetailLabel.frame.size.height + 3, costDetailLabel.frame.size.width, costDetailLabel.frame.size.height)];
    [_infoBar addSubview:costDetailLabel];
    
    _pauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_pauseButton setBackgroundColor:[Utils defaultLightColor]];
    [_pauseButton setAlpha:.9];
    [_pauseButton setFrame:CGRectMake(width * 1/2 - 75, height * .95 - 15, 150, 30)];
    [_pauseButton addTarget:self action:@selector(pauseTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *titleStr = [Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]];
    [_pauseButton.layer setCornerRadius:15];
    [_pauseButton setAttributedTitle: titleStr forState:UIControlStateNormal];
    
    _finishButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_finishButton setBackgroundColor:[Utils gasColor]];
    [_finishButton setAlpha:.9];
    [_finishButton setFrame:CGRectMake(width/2 - 75, height * .88 - 15, 150, 30)];
    [_finishButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    titleStr = [Utils defaultString:@"Finish" size:17 color:[UIColor whiteColor]];
    [_finishButton.layer setCornerRadius:15];
    [_finishButton setAttributedTitle: titleStr forState:UIControlStateNormal];

}

-(void) updateCarLabel {
//    NSMutableAttributedString *title;
//    if (![TripManager sharedManager].car) {
//        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:14 color:[UIColor lightGrayColor]]];
//        [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    } else {
//        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
//        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
//        [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
//    }
//    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
}

-(void) addPassengers {
    [_popup dismiss:YES];
    AddPassengersViewController *vc = [[AddPassengersViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changeCar {
    [_popup dismiss:YES];
    ChooseCarViewController *vc = [ChooseCarViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changeGasPrice {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [popupView setBackgroundColor:[Utils gasColor]];
    //    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    //    [topBar setBackgroundColor:[Utils defaultColor]];
    //    UILabel *title = [[UILabel alloc] init];
    //    [title setAttributedText: [Utils defaultString:@"Select MPG" size:18 color:[UIColor whiteColor]]];
    //    [title sizeToFit];
    //    [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
    //    [topBar addSubview:title];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, 30 , 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:cancelButton];
    //
    //    [popupView clipsToBounds];
    //    [popupView addSubview:topBar];
    
    
    _gasPriceField = [[UITextField alloc] initWithFrame:CGRectMake(popupView.frame.size.width/2 - (popupView.frame.size.width - 100)/2, popupView.frame.size.height * 1/4 - 40, popupView.frame.size.width - 100, 80)];
    [_gasPriceField setAttributedPlaceholder:[Utils defaultString:@"$0.00" size:45 color:[UIColor whiteColor]]];
    _gasPrice = @"";
    [_gasPriceField setBackgroundColor:[Utils gasLightColor]];
    [_gasPriceField.layer setCornerRadius:10];
    //[_mpgField setPlaceholder:@"0"];
    [_gasPriceField setTextAlignment:NSTextAlignmentCenter];
    //[mpgField setAttributedText:[Utils defaultString:@"" size:30 color:[UIColor blackColor]]];
    [_gasPriceField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:45]];
    [_gasPriceField setTextColor:[UIColor whiteColor]];
    [popupView addSubview:_gasPriceField];
    [_mpgField setUserInteractionEnabled:NO];
    //[_mpgField setKeyboardType:UIKeyboardTypeDecimalPad];
    //[_mpgField becomeFirstResponder];
    
    DecimalKeypad *keypad = [[DecimalKeypad alloc] initWithFrame:CGRectMake(0, popupView.frame.size.height/2 - 60, popupView.frame.size.width, popupView.frame.size.height/2)];
    [keypad setBackgroundColor:[Utils gasColor]];
    [keypad setTextColor:[UIColor whiteColor]];
    keypad.delegate = self;
    keypad.tag = 1;
    keypad.useDecimal = NO;
    [popupView addSubview:keypad];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [doneButton setBackgroundColor:[Utils gasLightColor]];
    [doneButton setFrame:CGRectMake(popupView.frame.size.width/2 - (popupView.frame.size.width - 100)/2, popupView.frame.size.height - 50, popupView.frame.size.width - 100, 40)];
    [doneButton addTarget:self action:@selector(selectGasPrice) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:doneButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Change" size:20 color:[UIColor whiteColor]];
    [doneButton.layer setCornerRadius:5];
    //[doneButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    //[doneButton.layer setBorderWidth:1];
    [doneButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToTop maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter)];
}

-(void)selectGasPrice {
    NSString *str = [_gasPriceField.text substringFromIndex:1];
    if ([str doubleValue]) {
        NSNumber *gasPrice = [NSNumber numberWithDouble: [str doubleValue]];
        [[TripManager sharedManager] setGasPrice:gasPrice];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[UIColor whiteColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor whiteColor]]];
        [_gasPriceButton setAttributedTitle:title forState:UIControlStateNormal];
        [self cancel];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Format" message:@"Please type in a valid Gas Price" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void) changeMPG {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [popupView setBackgroundColor:[Utils mpgColor]];
//    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
//    [topBar setBackgroundColor:[Utils defaultColor]];
//    UILabel *title = [[UILabel alloc] init];
//    [title setAttributedText: [Utils defaultString:@"Select MPG" size:18 color:[UIColor whiteColor]]];
//    [title sizeToFit];
//    [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
//    [topBar addSubview:title];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, 30 , 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:cancelButton];
//
//    [popupView clipsToBounds];
//    [popupView addSubview:topBar];
    
    
    _mpgField = [[UITextField alloc] initWithFrame:CGRectMake(popupView.frame.size.width/2 - (popupView.frame.size.width - 100)/2, popupView.frame.size.height * 1/4 - 40, popupView.frame.size.width - 100, 80)];
    [_mpgField setAttributedPlaceholder:[Utils defaultString:@"0" size:45 color:[UIColor whiteColor]]];
    [_mpgField setBackgroundColor:[Utils mpgLightColor]];
    [_mpgField.layer setCornerRadius:10];
    //[_mpgField setPlaceholder:@"0"];
    [_mpgField setTextAlignment:NSTextAlignmentCenter];
    //[mpgField setAttributedText:[Utils defaultString:@"" size:30 color:[UIColor blackColor]]];
    [_mpgField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:45]];
    [_mpgField setTextColor:[UIColor whiteColor]];
    [popupView addSubview:_mpgField];
    [_mpgField setUserInteractionEnabled:NO];
    //[_mpgField setKeyboardType:UIKeyboardTypeDecimalPad];
    //[_mpgField becomeFirstResponder];
    
    DecimalKeypad *keypad = [[DecimalKeypad alloc] initWithFrame:CGRectMake(0, popupView.frame.size.height/2 - 60, popupView.frame.size.width, popupView.frame.size.height/2)];
    [keypad setBackgroundColor:[Utils mpgColor]];
    [keypad setTextColor:[UIColor whiteColor]];
    keypad.delegate = self;
    keypad.tag = 0;
    [popupView addSubview:keypad];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [doneButton setBackgroundColor:[Utils mpgLightColor]];
    [doneButton setFrame:CGRectMake(popupView.frame.size.width/2 - (popupView.frame.size.width - 100)/2, popupView.frame.size.height - 50, popupView.frame.size.width - 100, 40)];
    [doneButton addTarget:self action:@selector(selectMPG) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:doneButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Change" size:20 color:[UIColor whiteColor]];
    [doneButton.layer setCornerRadius:5];
    //[doneButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    //[doneButton.layer setBorderWidth:1];
    [doneButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToTop maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter)];
}

-(void)keypad:(DecimalKeypad *)keypad didPressNumberValue:(NSString *)number {
    if (keypad.tag == 0) {
        _mpgField.text = [_mpgField.text stringByAppendingString:number];
    } else {
        if (_gasPrice.length < 3) {
            _gasPrice = [_gasPrice stringByAppendingString:number];
            if (_gasPrice.length == 0) {
                _gasPriceField.text = @"$0.00";
            } else if(_gasPrice.length == 1){
                _gasPriceField.text = [@"$0.0" stringByAppendingString:_gasPrice];
            }  else if(_gasPrice.length == 2){
                _gasPriceField.text = [@"$0." stringByAppendingString:_gasPrice];
            }  else if(_gasPrice.length == 3){
                _gasPriceField.text = [NSString stringWithFormat: @"$%@.%@", [_gasPrice substringToIndex:1], [_gasPrice substringFromIndex:1]];
            }
        }
    }
}

-(void)didBackspaceKeypad:(DecimalKeypad *)keypad {
    if (keypad.tag == 0) {
        if ([_mpgField.text length] > 0) {
            _mpgField.text = [_mpgField.text substringToIndex:[_mpgField.text length] - 1];
        }
    } else {
        if (_gasPrice.length > 0) {
            _gasPrice  = [_gasPrice substringToIndex:[_gasPrice length] - 1];
            if (_gasPrice.length == 0) {
                _gasPriceField.text = @"$0.00";
            } else if(_gasPrice.length == 1){
                _gasPriceField.text = [@"$0.0" stringByAppendingString:_gasPrice];
            }  else if(_gasPrice.length == 2){
                _gasPriceField.text = [@"$0." stringByAppendingString:_gasPrice];
            }  else if(_gasPrice.length == 3){
                _gasPriceField.text = [NSString stringWithFormat: @"$%@.%@", [_gasPrice substringToIndex:1], [_gasPrice substringFromIndex:1]];
            }
        }
    }
}

-(void)selectMPG {
    NSString *str = [_mpgField text];
    if ([str doubleValue]) {
        NSNumber *mpg = [NSNumber numberWithDouble: [str doubleValue]];
        [[TripManager sharedManager] setMpg:mpg];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[UIColor whiteColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor whiteColor]]];
        [_mpgButton setAttributedTitle:title forState:UIControlStateNormal];
        [self cancel];
        NSNumber *gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
        if ([gasPrice doubleValue] == 0) {
            [self changeGasPrice];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Format" message:@"Please type in a valid MPG" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)cancel {
    [_popup dismiss:YES];
}

-(void) startTrip {
    [TripManager sharedManager].status = RUNNING;
}

-(void) pauseTrip {
    NSAttributedString *title;
    if ([TripManager sharedManager].status == PAUSED) {
        [TripManager sharedManager].status = RUNNING;
        title = [Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]];
        [_finishButton removeFromSuperview];
    } else {
        [TripManager sharedManager].status = PAUSED;
        title = [Utils defaultString:@"Resume Trip" size:17 color:[UIColor whiteColor]];
        [_mapView addSubview:_finishButton];
    }
    [_pauseButton setAttributedTitle:title forState:UIControlStateNormal];
}

-(void) finishTrip {
    [KLCPopup dismissAllPopups];
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    [[TripManager sharedManager] setStatus:FINISHED];
    if (!_finishView) {
        _finishView = [[FinishView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    } else {
        [_finishView update];
    }
    
    _popup = [KLCPopup popupWithContentView:_finishView showType:KLCPopupShowTypeSlideInFromTop dismissType:KLCPopupDismissTypeSlideOutToTop maskType:KLCPopupMaskTypeClear dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup show];
}

-(void) saveTrips {
    [KLCPopup dismissAllPopups];
    _finishView = nil;
}

- (void) discardTrip {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Quit trip" message:@"This trip will not be saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
    alert.tag = 0;
    alert.delegate = self;
    [alert show];
    _finishView = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 0) {
        [[TripManager sharedManager] setStatus:FINISHED];
        [[TripManager sharedManager] setStatus:PENDING];
        _descriptionField = nil;
    } else if (buttonIndex == 1 && alertView.tag == 1) {
        [[UserManager sharedManager] loginWithBlock:^(BOOL loggedIn) {

        }];
    }
}

@end
