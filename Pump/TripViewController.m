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

@implementation TripViewController {
    MKMapView *_mapView;
    UIButton *_startButton;
}

-(void)viewDidLoad {
    [TripManager sharedManager];
    [self setupMapView];
}

#pragma MapView

-(void) setupMapView {
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    
    if ([TripManager sharedManager].status == PENDING) {
        [self setupPendingView];
    }
    
}

-(void) setupPendingView {
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    _startButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_startButton setBackgroundColor:[Utils defaultColor]];
    [_startButton setFrame:CGRectMake(width/2 - 40, height/2 - 15, 80, 30)];
    [_startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [Utils defaultString:@"Start Trip" size:20 color:[UIColor whiteColor]];
    [_startButton setAttributedTitle: title forState:UIControlStateNormal];
    [_mapView addSubview:_startButton];
}

-(void) startTrip {
    
}
@end
