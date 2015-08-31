//
//  TripManager.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripManager.h"

@implementation TripManager {
    NSMutableArray *_runningLocations;
    CLLocationManager *locationManager;
}

@synthesize distanceTraveled = _distanceTraveled;
@synthesize status = _status;

+ (TripManager *)sharedManager {
    static TripManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self == [super init]) {
        _runningLocations = [[NSMutableArray alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = 10;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            if ([CLLocationManager locationServicesEnabled]) {
                if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [locationManager requestWhenInUseAuthorization];
                } else {
                    [locationManager startUpdatingLocation];
                }
            }
        }
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (_status == RUNNING) {
        [_runningLocations addObject: [locations lastObject]];
        if (_runningLocations.count > 1) {
            _distanceTraveled += [[_runningLocations lastObject] distanceFromLocation:[_runningLocations objectAtIndex:_runningLocations.count - 2]];
            NSLog(@"%f", _distanceTraveled);
        }
        
        NSUInteger count = _runningLocations.count;
        CLLocationCoordinate2D coordinates[count];
        for (int i = 0; i < count; i++) {
            CLLocation *location = [_runningLocations objectAtIndex:i];
            CLLocationCoordinate2D coor = location.coordinate;
            coordinates[i] = coor;
        }
        
        _polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
        [self.delegate tripManager:self didUpdateLocationWith:_distanceTraveled and:_polyline];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [manager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
            } else {
                [locationManager startUpdatingLocation];
            }
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOCATION_AUTHORIZATION" object:nil];
    });
}

-(void)setStatus:(TripStatusType *)status {
    _status = status;
    if (_status == PENDING) {
        _runningLocations = [[NSMutableArray alloc] init];
        _distanceTraveled = 0;
    }
    else if (_status == RUNNING) {

    }
    [self.delegate tripManager:self didUpdateStatus:_status];
}


@end
