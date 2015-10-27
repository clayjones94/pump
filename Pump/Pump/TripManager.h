//
//  TripManager.h
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

@class TripManager;

@protocol TripManagerDelegate <NSObject>
@optional
- (void) tripManager: (TripManager *)manager didUpdateStatus: (TripStatusType)status;
- (void) tripManager: (TripManager *)manager didUpdateLocationWith: (CLLocationDistance) distance and:(GMSPolyline *)polyline;
- (void) tripManager: (TripManager *)manager didUpdateLocation: (CLLocationCoordinate2D) coor direction:(CLLocationDirection)direction;
@end


@interface TripManager : NSObject <CLLocationManagerDelegate>
@property id <TripManagerDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property GMSPolyline *polyline;
@property CLLocationDistance distanceTraveled;
@property (nonatomic) CLLocationDirection direction;
@property (nonatomic)TripStatusType status;
@property (nonatomic)NSNumber *mpg;
@property (nonatomic)NSNumber *gasPrice;
@property (nonatomic)NSMutableArray *passengers;
@property (nonatomic) BOOL includeUserAsPassenger;
@property (nonatomic) PFUser *car;

-(void)logoutOfManager;

+ (TripManager *)sharedManager;
@end
