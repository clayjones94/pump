//
//  TripInfoViewController.m
//  Pump
//
//  Created by Clay Jones on 9/16/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripInfoViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Database.h"
#import "Utils.h"

@interface TripInfoViewController ()

@end

@implementation TripInfoViewController {
    GMSMapView *_mapView;
    UILabel *_distanceLabel;
    UILabel *_costLabel;
    UILabel *_gasPriceLabel;
    UILabel *_mpgLabel;
    UILabel *_numPassengersLabel;
    UILabel *_driverIncludedLabel;
    UIView *_infoBar;
    NSDictionary *_trip;
}

@synthesize tripMembership = _tripMembership;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _infoBar = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 60)];
    [_infoBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_infoBar];
    
    _mapView = [GMSMapView mapWithFrame: CGRectMake(0, _infoBar.frame.origin.y + _infoBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (_infoBar.frame.origin.y + _infoBar.frame.size.height)) camera:[GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:0]];
    [self.view addSubview:_mapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"Trip Info"];
}

-(void)updateTripInfoBar {
    
    CGFloat width = _infoBar.frame.size.width;
    _distanceLabel = [[UILabel alloc] init];
    [_distanceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.2f", [[_trip objectForKey:@"distance"] floatValue]] size:18 color:[UIColor blackColor]]];
    [_distanceLabel sizeToFit];
    [_distanceLabel setFrame:CGRectMake(width * 3/8 - _distanceLabel.frame.size.width/2, (_infoBar.frame.size.height - _distanceLabel.frame.size.height)/2, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
    [_infoBar addSubview:_distanceLabel];
    
    UILabel *distanceDetailLabel = [[UILabel alloc] init];
    [distanceDetailLabel setAttributedText:[Utils defaultString:@"Distance" size:12 color:[UIColor darkGrayColor]]];
    [distanceDetailLabel sizeToFit];
    [distanceDetailLabel setFrame:CGRectMake(width * 3/8 - distanceDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y - distanceDetailLabel.frame.size.height + 3, distanceDetailLabel.frame.size.width, distanceDetailLabel.frame.size.height)];
    [_infoBar addSubview:distanceDetailLabel];
    
    UILabel *unitDetailLabel = [[UILabel alloc] init];
    [unitDetailLabel setAttributedText:[Utils defaultString:@"miles" size:10 color:[UIColor lightGrayColor]]];
    [unitDetailLabel sizeToFit];
    [unitDetailLabel setFrame:CGRectMake(width * 3/8 - unitDetailLabel.frame.size.width/2, _distanceLabel.frame.origin.y + _distanceLabel.frame.size.height - 6, unitDetailLabel.frame.size.width, unitDetailLabel.frame.size.height)];
    [_infoBar addSubview:unitDetailLabel];
    
    
    for (int i = 1; i <= 3; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(_infoBar.frame.size.width * i/4, _infoBar.frame.size.height * .2, 1, _infoBar.frame.size.height * .6)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [_infoBar addSubview:lineView];
    }
    
    _costLabel = [[UILabel alloc] init];
    [_costLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [[_trip objectForKey:@"distance"] floatValue] * [[_trip objectForKey:@"gas_price"] floatValue] / [[_trip objectForKey:@"mpg"] floatValue]] size:18 color:[UIColor blackColor]]];
    [_costLabel sizeToFit];
    [_costLabel setFrame:CGRectMake(self.view.frame.size.width * 1/8 - _costLabel.frame.size.width/2, (_infoBar.frame.size.height - _costLabel.frame.size.height)/2, _costLabel.frame.size.width, _costLabel.frame.size.height)];
    [_infoBar addSubview:_costLabel];
    
    UILabel *costDetailLabel = [[UILabel alloc] init];
    [costDetailLabel setAttributedText:[Utils defaultString:@"Total Cost" size:12 color:[UIColor darkGrayColor]]];
    [costDetailLabel sizeToFit];
    [costDetailLabel setFrame:CGRectMake(width * 1/8 - costDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - costDetailLabel.frame.size.height + 3, costDetailLabel.frame.size.width, costDetailLabel.frame.size.height)];
    [_infoBar addSubview:costDetailLabel];
    
    _mpgLabel = [[UILabel alloc] init];
    [_mpgLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"%.1f", [[_trip objectForKey:@"mpg"] floatValue]] size:18 color:[UIColor blackColor]]];
    [_mpgLabel sizeToFit];
    [_mpgLabel setFrame:CGRectMake(self.view.frame.size.width * 5/8 - _mpgLabel.frame.size.width/2, (_infoBar.frame.size.height - _mpgLabel.frame.size.height)/2, _mpgLabel.frame.size.width, _mpgLabel.frame.size.height)];
    [_infoBar addSubview:_mpgLabel];
    
    UILabel *mpgDetailLabel = [[UILabel alloc] init];
    [mpgDetailLabel setAttributedText:[Utils defaultString:@"MPG" size:12 color:[UIColor darkGrayColor]]];
    [mpgDetailLabel sizeToFit];
    [mpgDetailLabel setFrame:CGRectMake(width * 5/8 - mpgDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - mpgDetailLabel.frame.size.height + 3, mpgDetailLabel.frame.size.width, mpgDetailLabel.frame.size.height)];
    [_infoBar addSubview:mpgDetailLabel];
    
    _gasPriceLabel = [[UILabel alloc] init];
    [_gasPriceLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat: @"$%.2f", [[_trip objectForKey:@"gas_price"] floatValue]] size:18 color:[UIColor blackColor]]];
    [_gasPriceLabel sizeToFit];
    [_gasPriceLabel setFrame:CGRectMake(self.view.frame.size.width * 7/8 - _gasPriceLabel.frame.size.width/2, (_infoBar.frame.size.height - _gasPriceLabel.frame.size.height)/2, _gasPriceLabel.frame.size.width, _gasPriceLabel.frame.size.height)];
    [_infoBar addSubview:_gasPriceLabel];
    
    UILabel *gasDetailLabel = [[UILabel alloc] init];
    [gasDetailLabel setAttributedText:[Utils defaultString:@"Gas Price" size:12 color:[UIColor darkGrayColor]]];
    [gasDetailLabel sizeToFit];
    [gasDetailLabel setFrame:CGRectMake(width * 7/8 - gasDetailLabel.frame.size.width/2, _costLabel.frame.origin.y - gasDetailLabel.frame.size.height + 3, gasDetailLabel.frame.size.width, gasDetailLabel.frame.size.height)];
    [_infoBar addSubview:gasDetailLabel];
}

-(void)setTripMembership:(NSDictionary *)tripMembership {
    _tripMembership = tripMembership;
    
    [Database getTripWithID:[_tripMembership objectForKey:@"trip"] withBlock:^(NSDictionary *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _trip = data;
            [self updateTripInfoBar];
            GMSPath *path = [GMSPath pathFromEncodedPath:[data objectForKey:@"polyline"]];
            GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
            [polyline setStrokeWidth:5];
            //[polyline setStrokeColor:[Utils defaultColor]];
            polyline.map = _mapView;
            GMSMarker *start = [GMSMarker markerWithPosition:[polyline.path coordinateAtIndex:0]];
            GMSMarker *finish = [GMSMarker markerWithPosition:[polyline.path coordinateAtIndex:path.count - 1]];
            [start setIcon:[GMSMarker markerImageWithColor:[UIColor greenColor]]];
            [finish setIcon:[GMSMarker markerImageWithColor:[UIColor redColor]]];
            start.map = _mapView;
            finish.map = _mapView;
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:20];
            [_mapView animateWithCameraUpdate:update];
        });
    }];
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

@end
