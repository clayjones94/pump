//
//  Database.m
//  Pump
//
//  Created by Clay Jones on 9/3/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "AppDelegate.h"
#import "TripManager.h"
#import "Constants.h"
#import "UserManager.h"

@implementation Database {
    NSMutableArray *_modelYears;
}

#pragma Gas Feed Requests 

+(void) retrieveLocalGasPriceForType: (GasType) type withBlock:(void (^)(NSArray *data, NSError *error))block {
    CLLocationCoordinate2D coordinate = [TripManager sharedManager].locationManager.location.coordinate;
    NSDictionary *types = @{[NSNumber numberWithInteger:GAS_TYPE_REGULAR]:@"reg", [NSNumber numberWithInteger:GAS_TYPE_MIDGRADE]:@"mid", [NSNumber numberWithInteger:GAS_TYPE_PREMIUM]:@"pre", [NSNumber numberWithInteger:GAS_TYPE_DIESEL]:@"diesel"};
    NSString *gasType = [types objectForKey:[NSNumber numberWithInteger:type]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://api.mygasfeed.com/stations/radius/%f/%f/%f/%@/distance/6q6d99mop7.json", coordinate.latitude, coordinate.longitude, 5.0f,gasType]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([data length] > 0 && error == nil) {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSArray *stationArray = [dataDict objectForKey:@"stations"];
            if (stationArray.count > 0) {
                block(stationArray,error);
            } else {
                block(nil,error);
            }
        } else {
            block(nil,error);
        }
    }];
    
    [task resume];
}

#pragma VENMO Requests

+(void) retrieveVenmoFriendsWithLimit: (NSNumber *) limit withBlock:(void (^)(NSArray *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/users/%@/friends?access_token=%@&limit=%ld", [[[Venmo sharedInstance] session] user].externalId,[[[Venmo sharedInstance]session] accessToken], (long)[limit integerValue]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *friendArray = [dataDict objectForKey:@"data"];
        block(friendArray,error);
    }];
    
    [task resume];
}

+(void) retrieveVenmoFriendWithID:(NSString *)friendID withBlock:(void (^)(NSDictionary *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/users/%@?access_token=%@", friendID,[[[Venmo sharedInstance]session] accessToken]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *friend = [dataDict objectForKey:@"data"];
        block(friend,error);
    }];
    
    [task resume];
}

+(void) getCarYearswithBlock:(void (^)(NSData *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/vehicle/menu/year"]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

+(void) getCarMakesFromYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/vehicle/menu/make?year=%@", year]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

+(void) getCarModelsFromMake:(NSString *) make andYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block {
    make = [make stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?year=%@&make=%@", year, make]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

+(void) getCarFromModel: (NSString *) model make:(NSString *) make andYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block {
    model = [model stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=%@&make=%@&model=%@", year, make, model]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

+(void) getCarFromID: (NSString *) carID withBlock:(void (^)(NSData *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/vehicle/%@", carID]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

+(void) getMileageFromID: (NSString *) carID withBlock:(void (^)(NSData *data, NSError *error))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.fueleconomy.gov/ws/rest/ympg/shared/ympgVehicle/%@", carID]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        block(data, error);
    }];
    
    [task resume];
}

@end
