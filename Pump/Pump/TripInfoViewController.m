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
}

@synthesize tripMembership = _tripMembership;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _mapView = [GMSMapView mapWithFrame:self.view.frame camera:[GMSCameraPosition cameraWithTarget:_mapView.myLocation.coordinate zoom:0]];
    [self.view addSubview:_mapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"Trip Info"];
}

-(void)setTripMembership:(NSDictionary *)tripMembership {
    _tripMembership = tripMembership;
    
    [Database getTripWithID:[_tripMembership objectForKey:@"trip"] withBlock:^(NSDictionary *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GMSPath *path = [GMSPath pathFromEncodedPath:[data objectForKey:@"polyline"]];
            GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
            [polyline setStrokeWidth:5];
            //[polyline setStrokeColor:[Utils defaultColor]];
            polyline.map = _mapView;
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:20];
            [_mapView moveCamera:update];
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
