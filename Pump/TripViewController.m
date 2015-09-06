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
#import "CreateNewRequest.h"
#import "LoginViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>


@implementation TripViewController {
    MKMapView *_mapView;
    UIButton *_carButton;
    UIButton *_startButton;
    UIButton * _finishButton;
    UIButton *_pauseButton;
    UILabel *_distanceLabel;
    UILabel *_costLabel;
    UIView *_infoBar;
    KLCPopup *_popup;
}

-(void)viewDidLoad {
    [TripManager sharedManager].delegate = self;

    UIButton *newButton = [[UIButton alloc] init];
    [newButton setBackgroundImage:[UIImage imageNamed:@"new_request"] forState:UIControlStateNormal];
    [newButton setFrame:CGRectMake(0, 0, 25, 25)];
    [newButton addTarget:self action:@selector(createNewRequest) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    
    [self setupMapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[Venmo sharedInstance] isSessionValid]) {
        LoginViewController *loginvc = [LoginViewController new];
        [self presentViewController:loginvc animated:YES completion:nil];
    }
}

#pragma TripManagerDelegate

-(void)tripManager:(TripManager *)manager didUpdateStatus:(TripStatusType *)status {
    if(status == RUNNING) {
        [_startButton removeFromSuperview];
        [_mapView addSubview:_infoBar];
        [_mapView addSubview:_pauseButton];
        [_mapView addSubview:_finishButton];
        [_mapView addSubview:_carButton];
    } else if (status == FINISHED){
        
    }
}

-(void)tripManager:(TripManager *)manager didUpdateLocationWith:(CLLocationDistance)distance and:(MKPolyline *)polyline {
    [_mapView addOverlay:polyline];
    [_mapView setNeedsDisplay];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f mi", [TripManager sharedManager].distanceTraveled] size:17 color:[UIColor whiteColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(_infoBar.frame.size.width * 1/8 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
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
    [_startButton setFrame:CGRectMake(width/2 - 50, height/2 - 15, 100, 30)];
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
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, height * .9, width, height * .1)];
    [_infoBar setBackgroundColor:[Utils defaultColor]];
    
    _carButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_carButton setBackgroundColor:[Utils defaultColor]];
    [_carButton setFrame:CGRectMake(width * .05, height * .15, width * .9, 30)];
    [_carButton addTarget:self action:@selector(changeDriver) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"Driving your car" size:17 color:[UIColor whiteColor]];
    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
    [_carButton.layer setCornerRadius:3];
    [_carButton clipsToBounds];
    _carButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _carButton.layer.shadowOpacity = 0.8;
    _carButton.layer.shadowRadius = 3;
    _carButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    
    UIImageView *carImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"car"]];
    [carImage setFrame:CGRectMake(width * 2/16 - carImage.frame.size.width/2, (_infoBar.frame.size.height - carImage.frame.size.height)/2, carImage.frame.size.width, carImage.frame.size.height)];
    [_infoBar addSubview:carImage];
    
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f mi", [TripManager sharedManager].distanceTraveled/1609] size:15 color:[UIColor whiteColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 5/16 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    [_infoBar addSubview:_distanceLabel];
    
    UIImageView *costImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"money"]];
    [costImage setFrame:CGRectMake(width * 10/16 - costImage.frame.size.width/2, (_infoBar.frame.size.height - costImage.frame.size.height)/2, costImage.frame.size.width, costImage.frame.size.height)];
    [_infoBar addSubview:costImage];
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [TripManager sharedManager].distanceTraveled/1609 * 13.8] size:15 color:[UIColor whiteColor]]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(width * 13/16 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    [_infoBar addSubview:_costLabel];
    
    _pauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_pauseButton setBackgroundColor:[Utils defaultColor]];
    [_pauseButton setFrame:CGRectMake(width * 1/4 - 50, height * .85 - 15, 100, 30)];
    [_pauseButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    title = [Utils defaultString:@"Pause" size:17 color:[UIColor whiteColor]];
    [_pauseButton.layer setCornerRadius:3];
    _pauseButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _pauseButton.layer.shadowOpacity = 0.8;
    _pauseButton.layer.shadowRadius = 3;
    _pauseButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_pauseButton setAttributedTitle: title forState:UIControlStateNormal];
    
    _finishButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_finishButton setBackgroundColor:[UIColor redColor]];
    [_finishButton setFrame:CGRectMake(width * 3/4 - 50, height * .85 - 15, 100, 30)];
    [_finishButton addTarget:self action:@selector(finishTrip) forControlEvents:UIControlEventTouchUpInside];
    title = [Utils defaultString:@"Finish" size:17 color:[UIColor whiteColor]];
    [_finishButton.layer setCornerRadius:3];
    _finishButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _finishButton.layer.shadowOpacity = 0.8;
    _finishButton.layer.shadowRadius = 3;
    _finishButton.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    [_finishButton setAttributedTitle: title forState:UIControlStateNormal];

}

-(void) createNewRequest {
    CreateNewRequest *vc = [[CreateNewRequest alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) changeDriver {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .8, height * .8)];
    [popupView setBackgroundColor:[UIColor whiteColor]];
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupView.frame.size.width, 45)];
    [topBar setBackgroundColor:[Utils defaultColor]];
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Choose a car" size:18 color:[UIColor whiteColor]]];
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
    
    UIButton *myCarButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [myCarButton setBackgroundColor:[Utils defaultColor]];
    [myCarButton setFrame:CGRectMake(10, 55, popupView.frame.size.width - 20, 30)];
    [myCarButton addTarget:self action:@selector(selectMyCar) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:myCarButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"My Car" size:15 color:[UIColor whiteColor]];
    [myCarButton.layer setCornerRadius:5];
    [myCarButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    SearchUserView *searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, 95, popupView.frame.size.width, popupView.frame.size.width - 95)];
    [popupView addSubview:searchView];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup show];
}

-(void)selectMyCar {
    [self cancel];
}

-(void)cancel {
    [_popup dismiss:YES];
}

-(void) startTrip {
    [TripManager sharedManager].status = RUNNING;
}

-(void) finishTrip {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    UIView *popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width * .8, height * .8)];
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
    NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"Total Cost: %.2f", [TripManager sharedManager].distanceTraveled/1609] size:16 color:[UIColor grayColor]];
    [totalCostLabel setAttributedText:costString];
    [totalCostLabel sizeToFit];
    [totalCostLabel setFrame:CGRectMake(popupView.frame.size.width/2 - totalCostLabel.frame.size.width/2, 70 - totalCostLabel.frame.size.height/2, totalCostLabel.frame.size.width, totalCostLabel.frame.size.height)];
    
    [popupView addSubview:totalCostLabel];
    
    SearchUserView *searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, 95, popupView.frame.size.width, popupView.frame.size.width - 95)];
    //[searchView.tokenField setPlaceholderText: @"Choose passengers..."];
    [popupView addSubview:searchView];
    
    UIButton *venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setBackgroundColor:[Utils defaultColor]];
    [venmoButton setFrame:CGRectMake(popupView.frame.size.width/12 , popupView.frame.size.height * .9, popupView.frame.size.width/3, 30)];
    [venmoButton addTarget:self action:@selector(venmoPassengers) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:venmoButton];
    
    UIButton *saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [saveButton setBackgroundColor:[UIColor lightGrayColor]];
    [saveButton setFrame:CGRectMake(popupView.frame.size.width * 7/12 , popupView.frame.size.height * .9, popupView.frame.size.width/3, 30)];
    [saveButton addTarget:self action:@selector(saveTrips) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:saveButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Venmo" size:15 color:[UIColor whiteColor]];
    [venmoButton.layer setCornerRadius:5];
    [venmoButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    titleString = [Utils defaultString:@"Save" size:15 color:[UIColor whiteColor]];
    [saveButton.layer setCornerRadius:5];
    [saveButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _popup = [KLCPopup popupWithContentView:popupView showType:KLCPopupShowTypeBounceInFromTop dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [_popup show];
}

-(void) saveTrips {
    
}

- (void) venmoPassengers {
    
}

@end
