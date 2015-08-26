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
        
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
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
    if (RUNNING) {
        [_runningLocations addObject: [locations lastObject]];
        if (_runningLocations.count > 1) {
            _distanceTraveled += [[locations lastObject] distanceFromLocation:[locations objectAtIndex:locations.count - 2]];
        }
        
        CLLocationCoordinate2D coordinates[_runningLocations.count];
        for (int i = 0; i < _runningLocations.count; i++) {
            CLLocation *location = [_runningLocations objectAtIndex:i];
            coordinates[i] = location.coordinate;
        }
        
        _polyline = [MKPolyline polylineWithCoordinates:coordinates count:_runningLocations.count];
        [self.delegate tripManager:self didUpdateLocationWith:_distanceTraveled and:_polyline];
    }
}

-(void)setStatus:(TripStatusType *)status {
    _status = status;
    if (_status == PENDING) {
        _runningLocations = [[NSMutableArray alloc] init];
        _distanceTraveled = 0;
    }
    if (_status == RUNNING) {

    }
    [self.delegate tripManager:self didUpdateStatus:_status];
}


@end
