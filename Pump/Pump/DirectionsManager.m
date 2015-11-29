//
//  DirectionsManager.m
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "DirectionsManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TripManager.h"

@implementation DirectionsManager {
    NSArray *_steps;
    NSString *_destination;
    NSUInteger _currentPolylineIndex;
}

@synthesize currentStep = _currentStep;
@synthesize path = _path;
@synthesize isDirecting = _isDirecting;

+ (DirectionsManager *)sharedManager {
    static DirectionsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self == [super init]) {
        _isDirecting = NO;
        _currentStep = 0;
        _path = nil;
    }
    return self;
}

-(void)setPath:(GMSPath *)path {
    _path = path;
}

-(void) startDirectionsToLocationDescription: (NSString *) destDescription withBlock: (void (^)(NSError *error))block {
    [self fetchDirectionsFromLocationDescription:[TripManager sharedManager].locationManager.location.coordinate toLocationDescription:destDescription withBlock:^(NSArray *steps, GMSPath *path, NSError *error) {
        _steps = steps;
        _path = path;
        _currentStep = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                if (steps.count == 0) {
                    block([[NSError alloc] initWithDomain:@"No data" code:500 userInfo:nil]);
                } else {
                    block(error);
                }
            }
            if (_steps.count > 0) {
                [self.delegate managerDidChangeSteps:self];
                [self.delegate manager:self didUpdatePath:path];
            }
        });
    }];
}

-(void) startDirecting {
    if (_steps) {
        _isDirecting = YES;
        [self.delegate managerDidStartDirecting:self];
        [self checkBackgroundMode];
    }
}

-(void) endDirecting {
    _isDirecting = NO;
    _steps = nil;
    _path = nil;
    [self.delegate manager:self didUpdatePath:nil];
    _currentStep = 0;
    [self.delegate managerDidEndDirecting:self];
    [self checkBackgroundMode];
}

-(void) checkBackgroundMode {
    if ([TripManager sharedManager].status == RUNNING || [DirectionsManager sharedManager].isDirecting) {
        if([[TripManager sharedManager].locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]){
            [[TripManager sharedManager].locationManager setAllowsBackgroundLocationUpdates:YES];
        }
    } else {
        if([[TripManager sharedManager].locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]){
            [[TripManager sharedManager].locationManager setAllowsBackgroundLocationUpdates:NO];
        }
    }
}

-(NSAttributedString *) currentInstruction {
    if (_currentStep < _steps.count) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep];
        NSString * htmlString = stepDict[@"html_instructions"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        return attrStr;
    } else {
        return [[NSAttributedString alloc] initWithString: @"Arrive at destination"];
    }
}

-(NSAttributedString *) nextInstruction {
    if (_currentStep < _steps.count - 1) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep + 1];
        NSString * htmlString = stepDict[@"html_instructions"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        return attrStr;
    } else {
        return [[NSAttributedString alloc] initWithString: @"Arrive at destination"];
    }
}

-(UIImage *)currentManeuver {
    if (_currentStep < _steps.count) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep];
        NSString * maneuverString = stepDict[@"maneuver"];
        if (maneuverString) {
            return [UIImage imageNamed:maneuverString];
        }
    } else {
        return [UIImage imageNamed:@"straight"];
    }
    return [UIImage imageNamed:@"straight"];
}

-(UIImage *)nextManeuver {
    if (_currentStep < _steps.count - 1) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep + 1];
        NSString * maneuverString = stepDict[@"maneuver"];
        if (maneuverString) {
            return [UIImage imageNamed:maneuverString];
        }
    } else {
        return [UIImage imageNamed:@"straight"];
    }
    return [UIImage imageNamed:@"straight"];
}

-(CLLocationDirection) currentDirection{
     NSDictionary *stepDict = [_steps objectAtIndex:_currentStep];
    NSString *pathString = stepDict[@"polyline"][@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:pathString];
    if (_currentPolylineIndex < path.count - 1) {
        return GMSGeometryHeading([path coordinateAtIndex:_currentPolylineIndex], [path coordinateAtIndex:_currentPolylineIndex + 1]);
    } else {
        return GMSGeometryHeading([path coordinateAtIndex:_currentPolylineIndex - 1], [path coordinateAtIndex:_currentPolylineIndex]);
    }
}


-(void) updateLocationWithBlock: (void (^)(CLLocationDistance stepDistance, CLLocationDistance totalDistance, NSTimeInterval totalTime))block {
    if (_isDirecting) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep];
        CLLocation *currentLoc = [TripManager sharedManager].locationManager.location;
        NSString *pathString = stepDict[@"polyline"][@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:pathString];
        __block CLLocationDistance stepDistance;
        __block NSTimeInterval stepTime;
        [self distanceAndFractionFromCoordinate:currentLoc.coordinate toEndOfPath:path withBlock:^(CLLocationDistance distance, double fractionLeft) {
            stepDistance = distance;
            stepTime = [stepDict[@"duration"][@"value"] doubleValue] * fractionLeft;
        }];
        if (_currentStep != _steps.count - 1) {
            CLLocationDistance totalDistance = [self distanceFromSteps:[_steps subarrayWithRange:NSMakeRange(_currentStep + 1, _steps.count - _currentStep - 1)]];
            CLLocationDistance totalTime = [self timeFromSteps:[_steps subarrayWithRange:NSMakeRange(_currentStep + 1, _steps.count - _currentStep - 1)]];
            totalTime += stepTime;
            totalDistance += stepDistance;
            block(stepDistance, totalDistance, totalTime);
        } else {
            block(stepDistance, stepDistance, stepTime);
        }
        if (stepDistance == 0) {
            [self nextStep];
        }

        if(_path && !GMSGeometryIsLocationOnPathTolerance(currentLoc.coordinate, _path, NO, 15)) {
            [self startDirectionsToLocationDescription:_destination withBlock:nil];
        }
    }
}

-(void) nextStep {
    _currentStep ++;
    if (_currentStep == _steps.count) {
        [self endDirecting];
    } else {
        [self.delegate managerDidChangeSteps:self];
    }
    
}

-(void) fetchDirectionsFromLocationDescription: (CLLocationCoordinate2D) coor1 toLocationDescription: (NSString *)endString withBlock: (void (^)(NSArray *steps, GMSPath *path, NSError *error))block {
    
    _destination = endString;
    
    NSString *endText = [endString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSUInteger secsUtc1970 = [[NSDate date]timeIntervalSince1970];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=place_id:%@&departure_time=%lu&traffic_model=best_guess&key=AIzaSyBXLn6XVgKVl1rKT1BjgpN2IdkqPbFJ8E0", coor1.latitude, coor1.longitude, endText, (unsigned long)secsUtc1970]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *routesArray = [dataDict objectForKey:@"routes"];
        NSArray *legsArray = [routesArray.firstObject objectForKey:@"legs"];
        NSArray *stepsArray = legsArray.firstObject[@"steps"];
        GMSPath *path = [self pathFromSteps:stepsArray];
        block(stepsArray, path, error);
    }];
    
    [task resume];
}

-(GMSPath *) pathFromSteps: (NSArray *)steps {
    GMSMutablePath *totalPath = [GMSMutablePath path];
    for (NSUInteger i = 0; i < steps.count; i++) {
        NSDictionary *step = steps[i];
        NSString *pathString = step[@"polyline"][@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:pathString];
        for (NSUInteger j = 0; j < path.count; j++) {
            [totalPath addCoordinate: [path coordinateAtIndex:j]];
        }
    }
    return [[GMSPath alloc] initWithPath:totalPath];
}

-(CLLocationDistance) distanceFromSteps: (NSArray *)steps {
    CLLocationDistance totalPathDistance = 0;
    for (NSUInteger i = 0; i < steps.count; i++) {
        NSDictionary *step = steps[i];
        CLLocationDistance pathDistance = [step[@"distance"][@"value"] doubleValue];
        totalPathDistance += pathDistance;
    }
    return totalPathDistance;
}

-(NSTimeInterval) timeFromSteps: (NSArray *)steps {
    NSTimeInterval totalPathTime = 0;
    for (NSUInteger i = 0; i < steps.count; i++) {
        NSDictionary *step = steps[i];
        NSTimeInterval pathTime = [step[@"duration"][@"value"] doubleValue];
        totalPathTime += pathTime;
    }
    return totalPathTime;
}

-(void) distanceAndFractionFromCoordinate: (CLLocationCoordinate2D) coor toEndOfPath: (GMSPath *)path withBlock:(void (^)(CLLocationDistance distance, double fractionLeft))block {
    CLLocation *lastLocation = [[CLLocation alloc] initWithLatitude:((CLLocationCoordinate2D)[path coordinateAtIndex:0]).latitude longitude:((CLLocationCoordinate2D)[path coordinateAtIndex:0]).longitude];
    CLLocation *minDistanceLocation = lastLocation;
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude];
    CLLocationDistance minDistance = [minDistanceLocation distanceFromLocation:currentLocation];
    NSUInteger closestPointIndex = 0;
    CLLocationDistance totalDistance = 0;
    for (NSUInteger j = 1; j < path.count; j++) {
        CLLocationCoordinate2D point = [path coordinateAtIndex:j];
        CLLocation *pointLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        CLLocationDistance distance = [pointLocation distanceFromLocation:currentLocation];
        totalDistance += [lastLocation distanceFromLocation:pointLocation];
        if (distance < minDistance) {
            closestPointIndex = j;
            minDistanceLocation = pointLocation;
            minDistance = distance;
            totalDistance = 0;
        }
        lastLocation = pointLocation;
    }
    _currentPolylineIndex = closestPointIndex;
    block(totalDistance, ((double)path.count - (double)closestPointIndex)/(double)path.count);
};

@end
