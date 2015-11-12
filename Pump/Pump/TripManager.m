//
//  TripManager.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripManager.h"
#import "Database.h"
#import <Parse/Parse.h>

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
@synthesize stepInstruction = _stepInstruction;
@synthesize paymentStatuses = _paymentStatuses;

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
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
        
        _passengers = [NSMutableArray new];
        _polyline = [GMSPolyline new];
        _includeUserAsPassenger = YES;
        _car = nil;
        _mpg = [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"];
        if (!_mpg) {
            [self setMpg:@10];
        }
        
        [DirectionsManager sharedManager].delegate = self;
        
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

-(void)managerDidStartDirecting:(DirectionsManager *)manager {
    [self.delegate didStartDirectingTripManager:self];
}

-(void)manager:(DirectionsManager *)manager didUpdatePath:(GMSPath *)path {
    [self.delegate tripManager:self didUpdatePath:path];
}

-(void)managerDidChangeSteps:(DirectionsManager *)manager {
     _stepInstruction = [[DirectionsManager sharedManager] currentInstruction];
    UIImage *image = [manager currentManeuver];
    [self.delegate tripManager:self didUpdateInstructions:_stepInstruction withIcon:image];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];

    [self.delegate tripManager: self didUpdateLocation: newLocation.coordinate direction:0];
    if (_status == RUNNING || _status == PAUSED) {
        [_runningLocations addObject: newLocation];
        if (_runningLocations.count > 1 && _status != PAUSED && _lastLocation) {
            _distanceTraveled += [[_runningLocations lastObject] distanceFromLocation:_lastLocation];
        }
    
        _lastLocation = [_runningLocations lastObject];
        
//        NSUInteger count = _runningLocations.count;
//        GMSMutablePath *path = [[GMSMutablePath alloc] init];
//        for (int i = 0; i < count; i++) {
//            CLLocation *location = [_runningLocations objectAtIndex:i];
//            CLLocationCoordinate2D coor = location.coordinate;
//            [path addCoordinate:coor];
//        }
        
        double cost = _distanceTraveled / 1609.34 * [_gasPrice doubleValue] / [_mpg doubleValue];
        
        [self.delegate tripManager:self didUpdateCost:[NSNumber numberWithDouble:cost]];
    }
    [[DirectionsManager sharedManager] updateLocationWithBlock:^(CLLocationDistance stepDistance, CLLocationDistance totalDistance, NSTimeInterval totalTime) {
        [self.delegate tripManager:self didUpdateStepDistance:stepDistance totalDistance:totalDistance totalTime:totalTime];
    }];
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

-(void) setCar:(id) car {
    _car = car;
    if (!car) {
        [self setMpg:[[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"]];
    }
    [self.delegate tripManager:self didSelectCar:_car];
}

-(void)setGasPrice:(NSNumber *)gasPrice {
    _gasPrice = gasPrice;
}

-(void)setMpg:(NSNumber *)mpg {
    _mpg = mpg;
    [self.delegate tripManager:self didUpdateMPG:mpg];
}

-(void) selectGasType {
    GasType type = GAS_TYPE_REGULAR;
//    if ([_car[@"gas_type"] isEqualToString:@"Midgrade Gasoline"]) {
//        type = GAS_TYPE_MIDGRADE;
//    } else if([_car[@"gas_type"] isEqualToString:@"Premium Gasoline"]) {
//        type = GAS_TYPE_PREMIUM;
//    } else if ([_car[@"gas_type"] isEqualToString:@"Diesel Gasoline"]) {
//        type = GAS_TYPE_DIESEL;
//    }
    switch (type) {
        case GAS_TYPE_REGULAR:
        {
            [Database retrieveLocalGasPriceForType:GAS_TYPE_REGULAR withBlock:^(NSArray *data, NSError *error) {
                if (error) {
                    _gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
                    if (!_gasPrice) {
                        _gasPrice = @3.00;
                    }
                    return;
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                    double gasAverage = 0;
                    int count = 0;
                    for (NSDictionary *station in data) {
                        if([[station objectForKey:@"reg_price"] doubleValue]) {
                            count++;
                            gasAverage += [[station objectForKey:@"reg_price"] doubleValue];
                        }
                    }
                    gasAverage /= count++;
                    if (gasAverage > 0) {
                        NSNumber *gasPrice = [NSNumber numberWithDouble: gasAverage];
                        [self setGasPrice:gasPrice];
                    }
                //});
            }];
            break;
        }
        case GAS_TYPE_MIDGRADE:
        {
            [Database retrieveLocalGasPriceForType:GAS_TYPE_MIDGRADE withBlock:^(NSArray *data, NSError *error) {
                if (error) {
                    _gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
                    if (!_gasPrice) {
                        _gasPrice = @3.00;
                    }
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                    double gasAverage = 0;
                    int count = 0;
                    for (NSDictionary *station in data) {
                        if([[station objectForKey:@"mid_price"] doubleValue]) {
                            count++;
                            gasAverage += [[station objectForKey:@"mid_price"] doubleValue];
                        }
                        return;
                    }
                    gasAverage /= count++;
                    if (gasAverage > 0) {
                        NSNumber *gasPrice = [NSNumber numberWithDouble: gasAverage];
                        [self setGasPrice:gasPrice];
                    }
                //});
            }];
            break;
        }
        case GAS_TYPE_PREMIUM:
        {
            [Database retrieveLocalGasPriceForType:GAS_TYPE_PREMIUM withBlock:^(NSArray *data, NSError *error) {
                if (error) {
                    _gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
                    if (!_gasPrice) {
                        _gasPrice = @3.00;
                    }
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                    double gasAverage = 0;
                    int count = 0;
                    for (NSDictionary *station in data) {
                        if([[station objectForKey:@"pre_price"] doubleValue]) {
                            count++;
                            gasAverage += [[station objectForKey:@"pre_price"] doubleValue];
                        }
                        return;
                    }
                    gasAverage /= count++;
                    if (gasAverage > 0) {
                        NSNumber *gasPrice = [NSNumber numberWithDouble: gasAverage];
                        [self setGasPrice:gasPrice];
                    }
                //});
            }];
            break;
        }
        case GAS_TYPE_DIESEL:
        {
            [Database retrieveLocalGasPriceForType:GAS_TYPE_DIESEL withBlock:^(NSArray *data, NSError *error) {
                if (error) {
                    _gasPrice = [[NSUserDefaults standardUserDefaults] objectForKey:@"gas_price"];
                    if (!_gasPrice) {
                        _gasPrice = @3.00;
                    }
                    return;
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                    double gasAverage = 0;
                    int count = 0;
                    for (NSDictionary *station in data) {
                        if([[station objectForKey:@"diesel_price"] doubleValue]) {
                            count++;
                            gasAverage += [[station objectForKey:@"diesel_price"] doubleValue];
                        }
                    }
                    gasAverage /= count++;
                    if (gasAverage > 0) {
                        NSNumber *gasPrice = [NSNumber numberWithDouble: gasAverage];
                        [self setGasPrice:gasPrice];
                    }
                //});
            }];
            break;
        }
        default:
            break;
    }
}

-(void)setStatus:(TripStatusType)status {
    _status = status;
    if (_status == PENDING) {
        [self selectGasType];
        _runningLocations = [[NSMutableArray alloc] init];
        _distanceTraveled = 0;
        _includeUserAsPassenger = YES;
        _passengers = [NSMutableArray new];
        if (!_car || !_mpg) {
            [self setMpg: [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"]];
        }
    }
    else if (_status == RUNNING) {
        if (!_car) {
            [self setMpg: [[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"]];
        }
        if (!_mpg) {
            _mpg = @10;
        }
        [self selectGasType];
    } else if (_status == FINISHED) {
        _paymentStatuses = [[NSMutableArray alloc] init];
    }
    [self.delegate tripManager:self didUpdateStatus:_status];
}

-(void)logoutOfManager {
    [self setStatus:PENDING];
}

@end
