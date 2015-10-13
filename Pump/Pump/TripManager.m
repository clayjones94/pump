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
    CLLocation *_lastLocation;
}


@synthesize locationManager = _locationManager;
@synthesize distanceTraveled = _distanceTraveled;
@synthesize status = _status;
@synthesize mpg = _mpg;
@synthesize gasPrice = _gasPrice;
@synthesize passengers = _passengers;
@synthesize includeUserAsPassenger = _includeUserAsPassenger;
@synthesize car = _car;
@synthesize direction = _direction;

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
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
        
        _passengers = [NSMutableArray new];
        _polyline = [GMSPolyline new];
        _includeUserAsPassenger = YES;
        _car = nil;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            if ([CLLocationManager locationServicesEnabled]) {
                if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                    [_locationManager requestAlwaysAuthorization];
                } else {
                    [_locationManager startUpdatingLocation];
                }
            }
        }
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    if (_status != FINISHED) {
        _polyline.map = nil;
    }
//    CLLocationDirection direction = [self getHeadingForDirectionFromCoordinate:_lastLocation.coordinate toCoordinate:newLocation.coordinate];
//    if (ABS(_direction - direction) > 3) {
//        _direction = direction;
//        NSLog(@"Direction: %f", direction);
//    }
    [self.delegate tripManager: self didUpdateLocation: newLocation.coordinate direction:0];
    if (_status == RUNNING || _status == PAUSED) {
        [_runningLocations addObject: newLocation];
        if (_runningLocations.count > 1 && _status != PAUSED && _lastLocation) {
            _distanceTraveled += [[_runningLocations lastObject] distanceFromLocation:_lastLocation];
        }
    
        _lastLocation = [_runningLocations lastObject];
        
        NSUInteger count = _runningLocations.count;
        GMSMutablePath *path = [[GMSMutablePath alloc] init];
        for (int i = 0; i < count; i++) {
            CLLocation *location = [_runningLocations objectAtIndex:i];
            CLLocationCoordinate2D coor = location.coordinate;
            [path addCoordinate:coor];
        }
        
        _polyline = [GMSPolyline polylineWithPath:path];
        _polyline.strokeColor = [UIColor blueColor];
        _polyline.strokeWidth = 5.f;
        [self.delegate tripManager:self didUpdateLocationWith:_distanceTraveled and:_polyline];
    }
}

- (float) getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [manager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            } else {
                [_locationManager startUpdatingLocation];
            }
            break;
        default:
            break;
    }
}

-(void)setGasPrice:(NSNumber *)gasPrice {
    _gasPrice = gasPrice;
    [[NSUserDefaults standardUserDefaults] setObject:gasPrice forKey:@"gas_price"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setMpg:(NSNumber *)mpg {
    _mpg = mpg;
    [[NSUserDefaults standardUserDefaults] setObject:mpg forKey:@"mpg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)setStatus:(TripStatusType)status {
    _status = status;
    if (_status == PENDING) {
        _runningLocations = [[NSMutableArray alloc] init];
        _distanceTraveled = 0;
        _includeUserAsPassenger = YES;
        _passengers = [NSMutableArray new];
        _car = nil;
    }
    else if (_status == RUNNING) {
    }
    [self.delegate tripManager:self didUpdateStatus:_status];
}

-(void)logoutOfManager {
    [self setStatus:PENDING];
}

@end
