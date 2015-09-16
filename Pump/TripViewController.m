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


@implementation TripViewController {
    MKMapView *_mapView;
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
    UIButton *_passengersButton;
}

-(void)viewDidLoad {
    [TripManager sharedManager].delegate = self;
    [UserManager sharedManager];
    
    UIButton *profileButton = [[UIButton alloc] init];
    [profileButton setBackgroundImage:[UIImage imageNamed:@"wheel_icon"] forState:UIControlStateNormal];
    [profileButton setFrame:CGRectMake(0, 0, 25, 25)];
    [profileButton addTarget:self action:@selector(profileSelected) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: profileButton];
    
    [self setupMapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[Venmo sharedInstance] isSessionValid]) {
        LoginViewController *loginvc = [LoginViewController new];
        [self presentViewController:loginvc animated:YES completion:nil];
    }
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%lu", (unsigned long)[TripManager sharedManager].passengers.count] size:20 color:[Utils defaultColor]]];
    [titleStr appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rpassengers"] size:12 color:[UIColor lightGrayColor]]];
    [_passengersButton setAttributedTitle: titleStr forState:UIControlStateNormal];
}

-(void) profileSelected {
    ProfileViewController *vc = [ProfileViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma TripManagerDelegate

-(void)tripManager:(TripManager *)manager didUpdateStatus:(TripStatusType *)status {
    if(status == RUNNING) {
        [_startButton removeFromSuperview];
        [_mapView addSubview:_infoBar];
        [_mapView addSubview:_pauseButton];
    }  else if (status == PAUSED) {
    } else if (status == FINISHED){
        
    } else if (status == PENDING){
        [_pauseButton removeFromSuperview];
        [_finishButton removeFromSuperview];
        [_infoBar removeFromSuperview];
        [KLCPopup dismissAllPopups];
        [self setupPendingView];
    }
}

-(void)tripManager:(TripManager *)manager didUpdateLocationWith:(CLLocationDistance)distance and:(MKPolyline *)polyline {
    [_mapView addOverlay:polyline];
    [_mapView setNeedsDisplay];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609] size:36 color:[UIColor blackColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(_infoBar.frame.size.width * 1/4 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609 * [[TripManager sharedManager].gasPrice doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor blackColor]]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 3/4 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height * 3/2 - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
}

#pragma MapView

-(void) setupMapView {
//    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
//    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, [UIColor whiteColor]]
//                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
//
//    [self.navigationController.navigationBar setTitleTextAttributes:attrsDictionary];
//    [self.navigationController setTitle:@"Pump"];
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    _mapView.delegate = self;
    
    [self setupPendingView];
    [self setupRunningView];
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:[TripManager sharedManager].polyline];
    lineView.strokeColor = [Utils defaultColor];
    lineView.lineWidth = 7;
    return lineView;
}

-(void) setupPendingView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _startButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_startButton setBackgroundColor:[Utils defaultColor]];
    [_startButton setFrame:CGRectMake(width/2 - 50, height * .9 - 15, 100, 30)];
    [_startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"Start Trip" size:17 color:[UIColor whiteColor]];
    [_startButton setAttributedTitle: title forState:UIControlStateNormal];
    [_startButton.layer setCornerRadius:3];
    [_startButton clipsToBounds];
    _startButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _startButton.layer.shadowOpacity = 0.8;
    _startButton.layer.shadowRadius = 3;
    _startButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_mapView addSubview:_startButton];
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
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", [[TripManager sharedManager] mpg]] size:20 color:[Utils defaultColor]]];
    [title appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rmpg"] size:12 color:[UIColor lightGrayColor]]];
    [_mpgButton setAttributedTitle: title forState:UIControlStateNormal];
    //[_mpgButton sizeToFit];
    //[_mpgButton setFrame:CGRectMake(width * 3/16 - _mpgButton.frame.size.width/2, _infoBar.frame.size.height/4 - _mpgButton.frame.size.height/2, _mpgButton.frame.size.width, _mpgButton.frame.size.height)];
    [_mpgButton setFrame:CGRectMake(width * .025, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_mpgButton];
    
    _gasPriceButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_gasPriceButton.layer setBorderColor:[Utils defaultColor].CGColor];
    [_gasPriceButton.layer setBorderWidth:1];
    [_gasPriceButton.layer setCornerRadius:3];
    _gasPriceButton.titleLabel.numberOfLines = 2;
    _gasPriceButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_gasPriceButton addTarget:self action:@selector(changeGasPrice) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[[TripManager sharedManager] gasPrice]floatValue]] size:20 color:[Utils defaultColor]]];
    [titleStr appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rper gallon"] size:12 color:[UIColor lightGrayColor]]];
    [_gasPriceButton setAttributedTitle: titleStr forState:UIControlStateNormal];
    [_gasPriceButton setFrame:CGRectMake(width * .35, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_gasPriceButton];

    _passengersButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_passengersButton.layer setBorderColor:[Utils defaultColor].CGColor];
    [_passengersButton.layer setBorderWidth:1];
    [_passengersButton.layer setCornerRadius:3];
    _passengersButton.titleLabel.numberOfLines = 2;
    _passengersButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_passengersButton addTarget:self action:@selector(changePassengers) forControlEvents:UIControlEventTouchUpInside];
    titleStr = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%lu", (unsigned long)[TripManager sharedManager].passengers.count] size:20 color:[Utils defaultColor]]];
    [titleStr appendAttributedString:[Utils defaultString: [NSString stringWithFormat:@"\rpassengers"] size:12 color:[UIColor lightGrayColor]]];
    [_passengersButton setAttributedTitle: titleStr forState:UIControlStateNormal];
    [_passengersButton setFrame:CGRectMake(width * .675, _infoBar.frame.size.height/4 - _infoBar.frame.size.height * .2, width * .3, _infoBar.frame.size.height * .4)];
    [_infoBar addSubview:_passengersButton];
    
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [TripManager sharedManager].distanceTraveled/1609] size:36 color:[UIColor blackColor]]];
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
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_infoBar.frame.size.width/2, _infoBar.frame.size.height * .55, 1, _infoBar.frame.size.height * .4)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [_infoBar addSubview:lineView];
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:36 color:[UIColor blackColor]]];
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
    title = [Utils defaultString:@"Pause Trip" size:17 color:[UIColor whiteColor]];
    [_pauseButton.layer setCornerRadius:3];
    _pauseButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _pauseButton.layer.shadowOpacity = 0.8;
    _pauseButton.layer.shadowRadius = 3;
    _pauseButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_pauseButton setAttributedTitle: title forState:UIControlStateNormal];
    
    _finishButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_finishButton setBackgroundColor:[UIColor redColor]];
    [_finishButton setFrame:CGRectMake(width/2 - 75, height * .88 - 15, 150, 30)];
    [_finishButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    title = [Utils defaultString:@"Finish" size:17 color:[UIColor whiteColor]];
    [_finishButton.layer setCornerRadius:3];
    _finishButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _finishButton.layer.shadowOpacity = 0.8;
    _finishButton.layer.shadowRadius = 3;
    _finishButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_finishButton setAttributedTitle: title forState:UIControlStateNormal];

}

-(void) addPassengers {
    [KLCPopup dismissAllPopups];
    
    AddPassengersViewController *vc = [[AddPassengersViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changePassengers {
    if ([TripManager sharedManager].passengers.count == 0) {
        [self addPassengers];
    } else {
        CGFloat height = self.view.frame.size.height;
        CGFloat width = self.view.frame.size.width;
        UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .8, height * .8)];
        [popupView setBackgroundColor:[UIColor whiteColor]];
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
        [topBar setBackgroundColor:[Utils defaultColor]];
        UILabel *title = [[UILabel alloc] init];
        [title setAttributedText: [Utils defaultString:@"Passengers" size:18 color:[UIColor whiteColor]]];
        [title sizeToFit];
        [title setFrame:CGRectMake(topBar.frame.size.width/2 - title.frame.size.width/2, topBar.frame.size.height/2 - title.frame.size.height/2, title.frame.size.width, title.frame.size.height)];
        [topBar addSubview:title];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(10, topBar.frame.size.height/2 - 12.5, 25, 25)];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:cancelButton];
        
        PassengerView *passengerView = [[PassengerView alloc] initWithFrame:CGRectMake(0, 45, popupView.frame.size.width, popupView.frame.size.height-45)];
        
        [popupView addSubview:topBar];
        [popupView addSubview:passengerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPassengers) name:@"Add Passengers" object:nil];
        
        _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
        [_popup show];

    }
}

-(void) changeGasPrice {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .7, height * .3)];
    [popupView setBackgroundColor:[UIColor whiteColor]];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    [topBar setBackgroundColor:[Utils defaultColor]];
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Select Price" size:18 color:[UIColor whiteColor]]];
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
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .8, height * .3)];
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
    NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"$%.2f", [TripManager sharedManager].distanceTraveled/1609 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:30 color:[UIColor darkGrayColor]];
    [totalCostLabel setAttributedText:costString];
    [totalCostLabel sizeToFit];
    [totalCostLabel setFrame:CGRectMake(popupView.frame.size.width/2 - totalCostLabel.frame.size.width/2, 70 - totalCostLabel.frame.size.height/2, totalCostLabel.frame.size.width, totalCostLabel.frame.size.height)];
    
    [popupView addSubview:totalCostLabel];
    
    UIButton *discardButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [discardButton setBackgroundColor:[UIColor darkGrayColor]];
    [discardButton setFrame:CGRectMake(popupView.frame.size.width * 7/12 , popupView.frame.size.height * .7, popupView.frame.size.width/3, 30)];
    [discardButton addTarget:self action:@selector(venmoPassengers) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:discardButton];
    
    UIButton *saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [saveButton setBackgroundColor:[Utils defaultColor]];
    [saveButton setFrame:CGRectMake(popupView.frame.size.width * 1/12 , popupView.frame.size.height * .7, popupView.frame.size.width/3, 30)];
    [saveButton addTarget:self action:@selector(saveTrips) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:saveButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Discard" size:15 color:[UIColor whiteColor]];
    [discardButton.layer setCornerRadius:5];
    [discardButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    titleString = [Utils defaultString:@"Save" size:15 color:[UIColor whiteColor]];
    [saveButton.layer setCornerRadius:5];
    [saveButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup show];
}

-(void) saveTrips {
    [Database postTripWithDistance:[NSNumber numberWithInteger:[TripManager sharedManager].distanceTraveled/1609] gasPrice:[TripManager sharedManager].gasPrice mpg:[TripManager sharedManager].mpg andPassengerCount:[NSNumber numberWithInteger:[TripManager sharedManager].passengers.count] withBlock:^(NSDictionary *data) {
        for (NSDictionary *passenger in [TripManager sharedManager].passengers) {
            NSNumber *cost = [NSNumber numberWithInteger:[TripManager sharedManager].distanceTraveled/1609 * [[TripManager sharedManager].gasPrice doubleValue] / [[TripManager sharedManager].mpg doubleValue] / [TripManager sharedManager].passengers.count];
            [Database postTripMembershipWithOwner:[Venmo sharedInstance].session.user.externalId  member:[passenger objectForKey:@"id"] amount:cost andTrip:[data objectForKey:@"id"]];
        }
    }];
    
    [[TripManager sharedManager] setStatus:PENDING];

}

- (void) venmoPassengers {
    
}

@end
