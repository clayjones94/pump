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


@implementation TripViewController {
    //MKMapView *_mapView;
    GMSMapView *_mapView;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCarLabel) name:@"Select Car" object:nil];
    
    [self setupMapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[Venmo sharedInstance] isSessionValid]) {
        LoginViewController *loginvc = [LoginViewController new];
        [self presentViewController:loginvc animated:YES completion:nil];
    }
}

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

-(void)tripManager:(TripManager *)manager didUpdateStatus:(TripStatusType *)status {
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
        
    } else if (status == PENDING){
        [_pauseButton removeFromSuperview];
        [_finishButton removeFromSuperview];
        [_infoBar removeFromSuperview];
        [KLCPopup dismissAllPopups];
        [self setupPendingView];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _profileButton];
    }
}

-(void)tripManager:(TripManager *)manager didUpdateLocationWith:(CLLocationDistance)distance and:(GMSPolyline *)polyline {
    polyline.map = _mapView;
    [_mapView setNeedsDisplay];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[UIColor blackColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(_infoBar.frame.size.width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[TripManager sharedManager].gasPrice doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor blackColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
        [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[UIColor blackColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
}

-(void)tripManager:(TripManager *)manager didUpdateLocation:(CLLocationCoordinate2D)coor {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:coor zoom:14];
    [_mapView animateToCameraPosition:camera];
}

#pragma MapView

-(void) setupMapView {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:6];

    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    _mapView.myLocationEnabled = YES;
    [self.view addSubview: _mapView];

    
    [self setupPendingView];
    [self setupRunningView];
    
}

-(void) setupPendingView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _startButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_startButton setBackgroundColor:[Utils defaultColor]];
    [_startButton setFrame:CGRectMake(width * 1/2 - 75, height * .95 - 15, 150, 30)];
    [_startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"Start Trip" size:17 color:[UIColor whiteColor]];
    [_startButton setAttributedTitle: title forState:UIControlStateNormal];
    [_startButton.layer setCornerRadius:3];
    [_startButton clipsToBounds];
//    _startButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    _startButton.layer.shadowOpacity = 0.8;
//    _startButton.layer.shadowRadius = 3;
//    _startButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_mapView addSubview:_startButton];
}


-(void) updateInfoBar {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[UIColor blackColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor blackColor]]];
    if ([[[TripManager sharedManager] mpg] doubleValue] == 0) {
            [_costLabel setAttributedText:[Utils defaultString:@"$0.00" size:36 color:[UIColor blackColor]]];
    }
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    
    NSNumber *mpg = [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"];
    if ([mpg doubleValue] == 0) {
        [self changeMPG];
    } else {
        [[TripManager sharedManager] setMpg:mpg];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor lightGrayColor]]];
        [_mpgButton setAttributedTitle:title forState:UIControlStateNormal];
    }

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[Utils defaultColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor lightGrayColor]]];
    [_gasPriceButton setAttributedTitle:title forState:UIControlStateNormal];
    
    if (![TripManager sharedManager].car) {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:16 color:[UIColor lightGrayColor]]];
        [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [_carButton setAttributedTitle:title forState:UIControlStateNormal];
    } else {
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
        [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
        [_carButton setAttributedTitle:title forState:UIControlStateNormal];
    }
}

-(void) setupRunningView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, height * .24)];
    [_infoBar setBackgroundColor:[UIColor whiteColor]];
    
    _mpgButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_mpgButton.layer setBorderColor:[Utils defaultColor].CGColor];
    [_mpgButton.layer setBorderWidth:1];
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
    [_mpgButton setFrame:CGRectMake(width * .025, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_mpgButton];
    
    _gasPriceButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_gasPriceButton.layer setBorderColor:[Utils defaultColor].CGColor];
    [_gasPriceButton.layer setBorderWidth:1];
    [_gasPriceButton.layer setCornerRadius:3];
    _gasPriceButton.titleLabel.numberOfLines = 2;
    _gasPriceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_gasPriceButton addTarget:self action:@selector(changeGasPrice) forControlEvents:UIControlEventTouchUpInside];
    NSNumber *gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
    if (!gasPrice) {
        gasPrice = @0;
    }
    [[TripManager sharedManager] setGasPrice:gasPrice];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[Utils defaultColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor lightGrayColor]]];
    [_gasPriceButton setAttributedTitle:title forState:UIControlStateNormal];
    [_gasPriceButton setFrame:CGRectMake(width * .35, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_gasPriceButton];
    

    _carButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_carButton.layer setBorderWidth:1];
    [_carButton.layer setCornerRadius:3];
    _carButton.titleLabel.numberOfLines = 2;
    _carButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_carButton addTarget:self action:@selector(changeCar) forControlEvents:UIControlEventTouchUpInside];
    if (![TripManager sharedManager].car) {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:16 color:[UIColor lightGrayColor]]];
            [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    } else {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
            [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
    }
    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
    [_carButton setFrame:CGRectMake(width * .675, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_carButton];
    
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609.344] size:36 color:[UIColor blackColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    [_infoBar addSubview:_distanceLabel];
    
    UILabel *distanceDetailLabel = [[UILabel alloc] init];
    [distanceDetailLabel setAttributedText:[Utils defaultString:@"Distance" size:12 color:[UIColor darkGrayColor]]];
    [distanceDetailLabel sizeToFit];
    [distanceDetailLabel setFrame:CGRectMake(width * 1/4 - distanceDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y - distanceDetailLabel.frame.size.height + 3, distanceDetailLabel.frame.size.width, distanceDetailLabel.frame.size.height)];
    [_infoBar addSubview:distanceDetailLabel];
    
    UILabel *unitDetailLabel = [[UILabel alloc] init];
    [unitDetailLabel setAttributedText:[Utils defaultString:@"miles" size:10 color:[UIColor lightGrayColor]]];
    [unitDetailLabel sizeToFit];
    [unitDetailLabel setFrame:CGRectMake(width * 1/4 - unitDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y + _distanceLabel.frame.size.height - 6, unitDetailLabel.frame.size.width, unitDetailLabel.frame.size.height)];
    [_infoBar addSubview:unitDetailLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_infoBar.frame.size.width/2, _infoBar.frame.size.height * .65, 1, _infoBar.frame.size.height * .2)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_infoBar addSubview:lineView];
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor blackColor]]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    [_infoBar addSubview:_costLabel];
    
    UILabel *costDetailLabel = [[UILabel alloc] init];
    [costDetailLabel setAttributedText:[Utils defaultString:@"Cost" size:12 color:[UIColor darkGrayColor]]];
    [costDetailLabel sizeToFit];
    [costDetailLabel setFrame:CGRectMake(width * 3/4 - costDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - costDetailLabel.frame.size.height + 3, costDetailLabel.frame.size.width, costDetailLabel.frame.size.height)];
    [_infoBar addSubview:costDetailLabel];
    
    _pauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_pauseButton setBackgroundColor:[Utils defaultColor]];
    [_pauseButton setFrame:CGRectMake(width * 1/2 - 75, height * .95 - 15, 150, 30)];
    [_pauseButton addTarget:self action:@selector(pauseTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *titleStr = [Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]];
    [_pauseButton.layer setCornerRadius:3];
//    _pauseButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    _pauseButton.layer.shadowOpacity = 0.8;
//    _pauseButton.layer.shadowRadius = 3;
//    _pauseButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_pauseButton setAttributedTitle: titleStr forState:UIControlStateNormal];
    
    _finishButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_finishButton setBackgroundColor:[UIColor redColor]];
    [_finishButton setFrame:CGRectMake(width/2 - 75, height * .88 - 15, 150, 30)];
    [_finishButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    titleStr = [Utils defaultString:@"Finish" size:17 color:[UIColor whiteColor]];
    [_finishButton.layer setCornerRadius:3];
//    _finishButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    _finishButton.layer.shadowOpacity = 0.8;
//    _finishButton.layer.shadowRadius = 3;
//    _finishButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_finishButton setAttributedTitle: titleStr forState:UIControlStateNormal];

}

-(void) updateCarLabel {
    NSMutableAttributedString *title;
    if (![TripManager sharedManager].car) {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Use friend's\rcar"] size:14 color:[UIColor lightGrayColor]]];
        [_carButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    } else {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rcar"] size:12 color:[UIColor lightGrayColor]]];
        [_carButton.layer setBorderColor:[Utils defaultColor].CGColor];
    }
    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
}

-(void) addPassengers {
    [KLCPopup dismissAllPopups];
    AddPassengersViewController *vc = [[AddPassengersViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changeCar {
    ChooseCarViewController *vc = [ChooseCarViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changeGasPrice {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .7, height * .3)];
    [popupView setBackgroundColor:[UIColor whiteColor]];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    [topBar setBackgroundColor:[Utils defaultColor]];
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Gas Price" size:18 color:[UIColor whiteColor]]];
    [title sizeToFit];
    [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
    [topBar addSubview:title];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, topBar.frame.size.height/2 - 12.5, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:cancelButton];
    
    [popupView clipsToBounds];
    [popupView addSubview:topBar];
    
    _gasPriceField = [[UITextField alloc] initWithFrame:CGRectMake(50, 55, popupView.frame.size.width - 100, 50)];
    //[mpgField setAttributedPlaceholder:[Utils defaultString:@"MPG" size:30 color:[UIColor lightTextColor]]];
    [_gasPriceField setPlaceholder:@"Price"];
    [_gasPriceField setTextAlignment:NSTextAlignmentCenter];
    //[mpgField setAttributedText:[Utils defaultString:@"" size:30 color:[UIColor blackColor]]];
    [_gasPriceField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30]];
    [popupView addSubview:_gasPriceField];
    [_gasPriceField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_gasPriceField becomeFirstResponder];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [doneButton setBackgroundColor:[Utils defaultColor]];
    [doneButton setFrame:CGRectMake(20, popupView.frame.size.height - 50, popupView.frame.size.width - 40, 30)];
    [doneButton addTarget:self action:@selector(selectGasPrice) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:doneButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Done" size:15 color:[UIColor whiteColor]];
    [doneButton.layer setCornerRadius:5];
    [doneButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
}

-(void)selectGasPrice {
    NSString *str = [_gasPriceField text];
    if ([str doubleValue]) {
        NSNumber *gasPrice = [NSNumber numberWithDouble: [str doubleValue]];
        [[TripManager sharedManager] setGasPrice:gasPrice];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice] floatValue]] size:20 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor lightGrayColor]]];
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
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .7, height * .3)];
    [popupView setBackgroundColor:[UIColor whiteColor]];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    [topBar setBackgroundColor:[Utils defaultColor]];
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Select MPG" size:18 color:[UIColor whiteColor]]];
    [title sizeToFit];
    [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
    [topBar addSubview:title];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, topBar.frame.size.height/2 - 12.5, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:cancelButton];
    
    [popupView clipsToBounds];
    [popupView addSubview:topBar];
    
    _mpgField = [[UITextField alloc] initWithFrame:CGRectMake(50, 55, popupView.frame.size.width - 100, 50)];
    //[mpgField setAttributedPlaceholder:[Utils defaultString:@"MPG" size:30 color:[UIColor lightTextColor]]];
    [_mpgField setPlaceholder:@"MPG"];
    [_mpgField setTextAlignment:NSTextAlignmentCenter];
    //[mpgField setAttributedText:[Utils defaultString:@"" size:30 color:[UIColor blackColor]]];
    [_mpgField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30]];
    [popupView addSubview:_mpgField];
    [_mpgField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_mpgField becomeFirstResponder];
    
        UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [doneButton setBackgroundColor:[Utils defaultColor]];
        [doneButton setFrame:CGRectMake(20, popupView.frame.size.height - 50, popupView.frame.size.width - 40, 30)];
        [doneButton addTarget:self action:@selector(selectMPG) forControlEvents:UIControlEventTouchUpInside];
        [popupView addSubview:doneButton];
    
        NSAttributedString *titleString = [Utils defaultString:@"Done" size:15 color:[UIColor whiteColor]];
        [doneButton.layer setCornerRadius:5];
        [doneButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup showWithLayout:KLCPopupLayoutMake(KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutAboveCenter)];
}

-(void)selectMPG {
    NSString *str = [_mpgField text];
    if ([str doubleValue]) {
        NSNumber *mpg = [NSNumber numberWithDouble: [str doubleValue]];
        [[TripManager sharedManager] setMpg:mpg];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[Utils defaultColor]]];
        [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor lightGrayColor]]];
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
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .8, height * .8)];
    if ([TripManager sharedManager].car) {
        [popupView setFrame:CGRectMake(0, 0, width * .8, height * .3)];
    }
    [popupView setBackgroundColor:[UIColor whiteColor]];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    [topBar setBackgroundColor:[Utils defaultColor]];
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Finish Ride" size:18 color:[UIColor whiteColor]]];
    [title sizeToFit];
    [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
    [topBar addSubview:title];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(10, topBar.frame.size.height/2 - 12.5, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:cancelButton];
    
    [popupView clipsToBounds];
    [popupView addSubview:topBar];
    
    UILabel *totalCostLabel = [[UILabel alloc] init];
    NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:30 color:[UIColor darkGrayColor]];
    [totalCostLabel setAttributedText:costString];
    [totalCostLabel sizeToFit];
    [totalCostLabel setFrame:CGRectMake(popupView.frame.size.width/2 - totalCostLabel.frame.size.width/2, 75 - totalCostLabel.frame.size.height/2, totalCostLabel.frame.size.width, totalCostLabel.frame.size.height)];
    
    [popupView addSubview:totalCostLabel];
    
    UIButton *saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [saveButton setBackgroundColor:[Utils defaultColor]];
    [saveButton setFrame:CGRectMake(popupView.frame.size.width * .08 , popupView.frame.size.height * .9, popupView.frame.size.width * .84, 30)];
    [saveButton addTarget:self action:@selector(saveTrips:) forControlEvents:UIControlEventTouchUpInside];
    
    if (![TripManager sharedManager].car) {
        PassengerView *passengerView = [[PassengerView alloc] initWithFrame:CGRectMake(0, 45, popupView.frame.size.width, popupView.frame.size.height - 155)];
        [passengerView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [popupView addSubview:passengerView];
    } else {
        [saveButton setFrame:CGRectMake(popupView.frame.size.width * .08 , popupView.frame.size.height * .6, popupView.frame.size.width * .84, 30)];
    }
    
    NSAttributedString *titleString = [Utils defaultString:@"Complete" size:15 color:[UIColor whiteColor]];
    [saveButton.layer setCornerRadius:5];
    [saveButton setAttributedTitle: titleString forState:UIControlStateNormal];
    [saveButton setUserInteractionEnabled:YES];
    [popupView addSubview:saveButton];
    
    [_indicator setFrame:CGRectMake(popupView.frame.size.width/2 - 15, popupView.frame.size.height/2 - 15, 30, 30)];
    [popupView addSubview:_indicator];
    [_indicator setHidden:YES];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup show];
}

-(void) saveTrips: (UIButton *) sender {
    if (![TripManager sharedManager].car && [TripManager sharedManager].passengers.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"You must add passengers or a friend's car before completing this ride." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        [sender setUserInteractionEnabled:NO];
        [_indicator startAnimating];
        [_indicator setHidden:NO];
        if ([TripManager sharedManager].car) {
            [TripManager sharedManager].passengers = [NSMutableArray new];
            [_profileVC.segmentedControl setSelectedSegmentIndex:1];
            [[UserManager sharedManager] addFriendToRecents:[TripManager sharedManager].car];
        } else {
            [_profileVC.segmentedControl setSelectedSegmentIndex:0];
            for (NSDictionary *friend in [TripManager sharedManager].passengers) {
                [[UserManager sharedManager] addFriendToRecents:friend];
            }
        }
        [Database postTripWithDistance:[NSNumber numberWithDouble:[TripManager sharedManager].distanceTraveled/1609.344] gasPrice:[TripManager sharedManager].gasPrice mpg:[TripManager sharedManager].mpg polyline: [[[[TripManager sharedManager] polyline] path] encodedPath] includeUser: [TripManager sharedManager].includeUserAsPassenger  andPassengers: [TripManager sharedManager].passengers withBlock:^(NSDictionary *data, NSError *error) {
            if (!error) {
                [_indicator stopAnimating];
                [_indicator setHidden:YES];
                if (_profileVC) {
                    [_profileVC refresh];
                }
                [self profileSelected];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TripManager sharedManager].passengers = [NSMutableArray new];
                    [[TripManager sharedManager] setStatus:PENDING];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_indicator stopAnimating];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Cannot connect to server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                });
                [sender setUserInteractionEnabled:YES];
            }
        }];
    }
}

- (void) discardTrip {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Quit trip" message:@"This trip will not be saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[TripManager sharedManager] setStatus:PENDING];
    }
}

@end
