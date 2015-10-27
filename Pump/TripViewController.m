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

@implementation TripViewController {
    //MKMapView *_mapView;
    GMSMapView *_mapView;
    UIButton *_myLocationButton;
    UIButton *_startButton;
    UIButton * _finishButton;
    UIButton *_pauseButton;
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
}

@synthesize user = _user;

-(void)viewDidLoad {
    [super viewDidLoad];
    [TripManager sharedManager].delegate = self;
    [UserManager sharedManager];
    
    [[PFUser currentUser] fetch];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    tracking = YES;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTrip) name:@"Show Popup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTrip) name:@"Select Car" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTrips) name:@"Save Trips" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:_popup selector:@selector(dismiss:) name:@"Discard Trip" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotificationCount) name:@"Recieve Notification" object:nil];
}

-(void)viewWillLayoutSubviews {
    [self setupMapView];
    [self setupPendingView];
    [self setupRunningView];
    
    if ([PFUser currentUser] && ![[PFUser currentUser][@"using_car"]boolValue]) {
        NoCarViewController *vc = [NoCarViewController new];
        //[vc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [nav setNavigationBarHidden:YES];
        [self addChildViewController:nav];
        [nav.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:nav.view];
        [nav didMoveToParentViewController:self];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser] && ![[PFUser currentUser][@"using_car"]boolValue]) {
        NoCarViewController *vc = [NoCarViewController new];
        //[vc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        //[nav setNavigationBarHidden:YES];
        [self addChildViewController:nav];
        [nav.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:nav.view];
        [nav didMoveToParentViewController:self];
    }
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
    if(status == RUNNING) {
        [TripManager sharedManager].car = _user;
        [_startButton removeFromSuperview];
        [_mapView addSubview:_infoBar];
        [_mapView addSubview:_pauseButton];
        [self updateInfoBar];
        [_pauseButton setAttributedTitle:[Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _cancelButton];
    }  else if (status == PAUSED) {
        [_pauseButton setAttributedTitle:[Utils defaultString:@"Resume Trip" size:17 color:[UIColor whiteColor]] forState:UIControlStateNormal];
    } else if (status == FINISHED){
        [_mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
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
        [_mapView setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
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
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString: [Utils defaultString:[NSString stringWithFormat: @"%.1f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[UIColor whiteColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"mi"] size:16 color:[UIColor whiteColor]]];
    [_distanceLabel setAttributedText:title];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(_infoBar.frame.size.width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 4/3 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[TripManager sharedManager].gasPrice doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor whiteColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
        [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[UIColor whiteColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 4/3 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
}

-(void)tripManager:(TripManager *)manager didUpdateLocation:(CLLocationCoordinate2D)coor direction:(CLLocationDirection)direction {
    if (tracking) {
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
    
    
    GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:target zoom:17];
    
    
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
    CGFloat height = _mapView.frame.size.height;
    CGFloat width = _mapView.frame.size.width;
    _startButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_startButton setBackgroundColor:[Utils defaultColor]];
    [_startButton setAlpha:.9];
    [_startButton setFrame:CGRectMake(width * .1, height * .95 - 15, width * .8, 30)];
    [_startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"START" size:17 color:[UIColor whiteColor]];
    [_startButton setAttributedTitle: title forState:UIControlStateNormal];
    [_startButton.layer setCornerRadius:4];
    [_startButton clipsToBounds];
    [_mapView addSubview:_startButton];
}


-(void) updateInfoBar {
    CGFloat width = _mapView.frame.size.width;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString: [Utils defaultString:[NSString stringWithFormat: @"%.1f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[UIColor whiteColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"mi"] size:16 color:[UIColor whiteColor]]];
    [_distanceLabel setAttributedText:title];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor whiteColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
            [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[UIColor whiteColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];

}

-(void) setupRunningView {
    CGFloat height = _mapView.frame.size.height;
    CGFloat width = _mapView.frame.size.width;
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height * .18)];
    [_infoBar setBackgroundColor:[UIColor clearColor]];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, _infoBar.frame.size.height)];
    [backgroundView setBackgroundColor:[Utils defaultColor]];
    [backgroundView setAlpha:.6];
    [_infoBar addSubview:backgroundView];
    [_infoBar sendSubviewToBack:backgroundView];
    
    UIColor *freeLabelColor = [UIColor whiteColor];
    
    _distanceLabel = [[UILabel alloc] init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString: [Utils defaultString:[NSString stringWithFormat: @"%.1f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:freeLabelColor]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"mi"] size:16 color:[UIColor whiteColor]]];
    [_distanceLabel setAttributedText:title];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 4/3 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    [_infoBar addSubview:_distanceLabel];
    
    UILabel *distanceDetailLabel = [[UILabel alloc] init];
    [distanceDetailLabel setAttributedText:[Utils defaultString:@"Distance" size:12 color:freeLabelColor]];
    [distanceDetailLabel sizeToFit];
    [distanceDetailLabel setFrame:CGRectMake(width * 1/4 - distanceDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y - distanceDetailLabel.frame.size.height + 3, distanceDetailLabel.frame.size.width, distanceDetailLabel.frame.size.height)];
    //[_infoBar addSubview:distanceDetailLabel];
    
    UILabel *unitDetailLabel = [[UILabel alloc] init];
    [unitDetailLabel setAttributedText:[Utils defaultString:@"miles" size:10 color:freeLabelColor]];
    [unitDetailLabel sizeToFit];
    [unitDetailLabel setFrame:CGRectMake(width * 1/4 - unitDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y + _distanceLabel.frame.size.height - 6, unitDetailLabel.frame.size.width, unitDetailLabel.frame.size.height)];
    //[_infoBar addSubview:unitDetailLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_infoBar.frame.size.width/2, _infoBar.frame.size.height * .65, 1, _infoBar.frame.size.height * .2)];
    lineView.backgroundColor = freeLabelColor;
    [_infoBar addSubview:lineView];
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:freeLabelColor]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 4/3 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    [_infoBar addSubview:_costLabel];
    
    UILabel *costDetailLabel = [[UILabel alloc] init];
    [costDetailLabel setAttributedText:[Utils defaultString:@"Cost" size:12 color:freeLabelColor]];
    [costDetailLabel sizeToFit];
    [costDetailLabel setFrame:CGRectMake(width * 3/4 - costDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - costDetailLabel.frame.size.height + 3, costDetailLabel.frame.size.width, costDetailLabel.frame.size.height)];
    
    _pauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_pauseButton setBackgroundColor:[Utils defaultColor]];
    [_pauseButton setAlpha:.9];
    [_pauseButton setFrame:CGRectMake(width * 1/2 - 75, height * .95 - 15, 150, 30)];
    [_pauseButton addTarget:self action:@selector(pauseTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *titleStr = [Utils defaultString:@"PAUSE" size:17 color:[UIColor whiteColor]];
    [_pauseButton.layer setCornerRadius:15];
    [_pauseButton setAttributedTitle: titleStr forState:UIControlStateNormal];
    
    _finishButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_finishButton setBackgroundColor:[Utils gasColor]];
    [_finishButton setAlpha:.9];
    [_finishButton setFrame:CGRectMake(width/2 - 75, height * .88 - 15, 150, 30)];
    [_finishButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    titleStr = [Utils defaultString:@"FINISH" size:17 color:[UIColor whiteColor]];
    [_finishButton.layer setCornerRadius:15];
    [_finishButton setAttributedTitle: titleStr forState:UIControlStateNormal];

}


//-(void)keypad:(DecimalKeypad *)keypad didPressNumberValue:(NSString *)number {
//    if (keypad.tag == 0) {
//        _mpgField.text = [_mpgField.text stringByAppendingString:number];
//    } else {
//        if (_gasPrice.length < 3) {
//            _gasPrice = [_gasPrice stringByAppendingString:number];
//            if (_gasPrice.length == 0) {
//                _gasPriceField.text = @"$0.00";
//            } else if(_gasPrice.length == 1){
//                _gasPriceField.text = [@"$0.0" stringByAppendingString:_gasPrice];
//            }  else if(_gasPrice.length == 2){
//                _gasPriceField.text = [@"$0." stringByAppendingString:_gasPrice];
//            }  else if(_gasPrice.length == 3){
//                _gasPriceField.text = [NSString stringWithFormat: @"$%@.%@", [_gasPrice substringToIndex:1], [_gasPrice substringFromIndex:1]];
//            }
//        }
//    }
//}
//
//-(void)didBackspaceKeypad:(DecimalKeypad *)keypad {
//    if (keypad.tag == 0) {
//        if ([_mpgField.text length] > 0) {
//            _mpgField.text = [_mpgField.text substringToIndex:[_mpgField.text length] - 1];
//        }
//    } else {
//        if (_gasPrice.length > 0) {
//            _gasPrice  = [_gasPrice substringToIndex:[_gasPrice length] - 1];
//            if (_gasPrice.length == 0) {
//                _gasPriceField.text = @"$0.00";
//            } else if(_gasPrice.length == 1){
//                _gasPriceField.text = [@"$0.0" stringByAppendingString:_gasPrice];
//            }  else if(_gasPrice.length == 2){
//                _gasPriceField.text = [@"$0." stringByAppendingString:_gasPrice];
//            }  else if(_gasPrice.length == 3){
//                _gasPriceField.text = [NSString stringWithFormat: @"$%@.%@", [_gasPrice substringToIndex:1], [_gasPrice substringFromIndex:1]];
//            }
//        }
//    }
//}

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
    [[TripManager sharedManager] setStatus:FINISHED];
    
    FinishViewController *vc = [FinishViewController new];
//    if (!_finishView) {
//        _finishView = [[FinishView alloc] initWithFrame:vc.view.frame];
//    } else {
//        [_finishView update];
//    }
    
    [self presentViewController:vc animated:YES completion:nil];
}

-(void) saveTrips {
    [KLCPopup dismissAllPopups];
    if (_historyVC) {
        [_historyVC refresh];
    }
    [self profileSelected];
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
    } else if (buttonIndex == 1 && alertView.tag == 1) {
        [[UserManager sharedManager] loginWithBlock:^(BOOL loggedIn) {

        }];
    }
}

@end
