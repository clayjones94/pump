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

-(void) startDirectionsToLocationDescription: (NSString *) destDescription {
    [self fetchDirectionsFromLocationDescription:[TripManager sharedManager].locationManager.location.coordinate toLocationDescription:destDescription withBlock:^(NSArray *steps, GMSPath *path, NSError *error) {
        _steps = steps;
        _path = path;
        [self.delegate manager:self didUpdatePath:path];
        _currentStep = 0;
        [self.delegate managerDidChangeSteps:self];
    }];
}

-(void) startDirecting {
    if (_steps) {
        _isDirecting = YES;
        [self.delegate managerDidStartDirecting:self];
    }
}

-(void) endDirecting {
    _isDirecting = NO;
    _steps = nil;
    _path = nil;
    [self.delegate manager:self didUpdatePath:nil];
    _currentStep = 0;
}

-(NSAttributedString *) currentInstruction {
    if (_currentStep < _steps.count) {
        NSDictionary *stepDict = [_steps objectAtIndex:_currentStep];
        NSString * htmlString = stepDict[@"html_instructions"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        NSLog(@"Current Instruction: %@", attrStr.string);
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
        NSLog(@"Next Instruction: %@", attrStr.string);
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
//            NSDictionary *iconDict = @{
//                    @"turn-sharp-left":[UIImage imageNamed:@"turn-sharp-left"],
//                    @"uturn-right":[UIImage imageNamed:@"uturn-right"],
//                    @"turn-slight-right":[UIImage imageNamed:@"turn-slight-right"],
//                    @"merge":[UIImage imageNamed:@"merge"],
//                    @"roundabout-left":[UIImage imageNamed:@"roundabout-left"],
//                    @"roundabout-right":[UIImage imageNamed:@"roundabout-right"],
//                    @"uturn-left":[UIImage imageNamed:@"uturn-left"],
//                    @"turn-slight-left":[UIImage imageNamed:@"turn-slight-left"],
//                    @"turn-left":[UIImage imageNamed:@"turn-left"],
//                    @"ramp-right":[UIImage imageNamed:@"ramp-right"],
//                    @"turn-right":[UIImage imageNamed:@"turn-right"],
//                    @"fork-right":[UIImage imageNamed:@"fork-right"],
//                    @"straight":[UIImage imageNamed:@"straight"],
//                    @"fork-left":[UIImage imageNamed:@"fork-left"],
//                    @"ferry-train":[UIImage imageNamed:@"ferry-train"],
//                    @"turn-sharp-right":[UIImage imageNamed:@"turn-sharp-right"],
//                    @"ramp-left":[UIImage imageNamed:@"ramp-left"],
//                    @"ferry":[UIImage imageNamed:@"ferry"],
//                    };
            NSLog(@"Current Maneuver: %@", maneuverString);
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
            //            NSDictionary *iconDict = @{
            //                    @"turn-sharp-left":[UIImage imageNamed:@"turn-sharp-left"],
            //                    @"uturn-right":[UIImage imageNamed:@"uturn-right"],
            //                    @"turn-slight-right":[UIImage imageNamed:@"turn-slight-right"],
            //                    @"merge":[UIImage imageNamed:@"merge"],
            //                    @"roundabout-left":[UIImage imageNamed:@"roundabout-left"],
            //                    @"roundabout-right":[UIImage imageNamed:@"roundabout-right"],
            //                    @"uturn-left":[UIImage imageNamed:@"uturn-left"],
            //                    @"turn-slight-left":[UIImage imageNamed:@"turn-slight-left"],
            //                    @"turn-left":[UIImage imageNamed:@"turn-left"],
            //                    @"ramp-right":[UIImage imageNamed:@"ramp-right"],
            //                    @"turn-right":[UIImage imageNamed:@"turn-right"],
            //                    @"fork-right":[UIImage imageNamed:@"fork-right"],
            //                    @"straight":[UIImage imageNamed:@"straight"],
            //                    @"fork-left":[UIImage imageNamed:@"fork-left"],
            //                    @"ferry-train":[UIImage imageNamed:@"ferry-train"],
            //                    @"turn-sharp-right":[UIImage imageNamed:@"turn-sharp-right"],
            //                    @"ramp-left":[UIImage imageNamed:@"ramp-left"],
            //                    @"ferry":[UIImage imageNamed:@"ferry"],
            //                    };
            NSLog(@"Next Maneuver: %@", maneuverString);
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

        if(!GMSGeometryIsLocationOnPathTolerance(currentLoc.coordinate, _path, NO, 15)) {
            [self startDirectionsToLocationDescription:_destination];
        }
    }
}

-(void) nextStep {
    _currentStep ++;
    [self.delegate managerDidChangeSteps:self];
    if (_currentStep == _steps.count) {
        [self endDirecting];
    }
    
}

-(void) fetchDirectionsFromLocationDescription: (CLLocationCoordinate2D) coor1 toLocationDescription: (NSString *)endString withBlock: (void (^)(NSArray *steps, GMSPath *path, NSError *error))block {
    
    _destination = endString;
    
    NSString *endText = [endString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=place_id:%@&key=AIzaSyBXLn6XVgKVl1rKT1BjgpN2IdkqPbFJ8E0", coor1.latitude, coor1.longitude, endText]]];
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