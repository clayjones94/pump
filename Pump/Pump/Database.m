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
#import "Friend.h"
#import "TripManager.h"
#import "Constants.h"
#import "UserManager.h"
#import "Storage.h"

@implementation Database

NSString *const URL = @"https://pump-start.herokuapp.com";
//NSString *const URL = @"http://0.0.0.0:5000";

+(void) authUserWithVenmoWithBlock:(void (^)(BOOL success))block  {
    NSString *url = [NSString stringWithFormat: @"users/auth/%@", [Venmo sharedInstance].session.user.externalId];
    
    NSDictionary *data;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id APNSToken = [defaults objectForKey:APNS_TOKEN_KEY];
    if (APNSToken == nil) {
        APNSToken = [NSNull null];
        data = @{
                 @"notification_count": @0
                 };
    } else {
        data = @{
                 @"notification_count": @0,
                 @"apns_token": APNSToken
                 };
    }
    
    [self makePOSTRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        if (data) {
            NSDictionary *dataDict = data;
            long num = [[dataDict objectForKey:@"id"] longValue];
            [defaults setObject:[NSNumber numberWithLong:num] forKey:PUMP_USER_ID_KEY];
            [defaults synchronize];
            block(YES);
        } else {
            block(NO);
        }
    }];
}

+ (void)updateBadgeCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [defaults objectForKey:PUMP_USER_ID_KEY];
    if (userID) {
        NSString *url =[NSString stringWithFormat: @"users/%@", userID];
        
        NSDictionary *data = @{
                               @"notification_count": @0
                               };
        [self makePATCHRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        }];
    }
}

+ (void) logoutUser {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:PUMP_USER_ID_KEY];
    [defaults synchronize];
    [[TripManager sharedManager] logoutOfManager];
    [[Storage sharedManager] logoutOfManager];
    [[UserManager sharedManager] logoutOfManager];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"recents"];
        [userDefaults synchronize];
    });
}

+ (void)updateAPNSToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id userID = [defaults objectForKey:PUMP_USER_ID_KEY];
    if (userID) {
        NSString *url =[NSString stringWithFormat: @"users/%@", userID];
        
        id APNSToken = [defaults objectForKey:APNS_TOKEN_KEY];
        if (APNSToken == nil) {
            APNSToken = [NSNull null];
        }
        
        NSDictionary *data = @{
                               @"apns_token": APNSToken
                               };
        [self makePATCHRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        }];
    }
}

+(void) getTripOwnershipsWithID: (NSString *) owner andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data, NSError *error))block{
    NSString *url = [NSString stringWithFormat:@"trip_memberships/owner/%@/status/%lu", owner, (unsigned long)status];
    [self makeGETRequestToURL:url withData:nil andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}


+(void) getTripMembershipsWithID: (NSString *) member andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data, NSError *error))block{
    NSString *url = [NSString stringWithFormat:@"trip_memberships/member/%@/status/%lu", member, (unsigned long)status];
    [self makeGETRequestToURL:url withData:nil andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

+(void) getCompleteTripMembershipsWithID: (NSString *) member withBlock: (void (^)(NSArray *data, NSError *error))block{
    NSString *url = [NSString stringWithFormat:@"trip_memberships/completeForUser/%@", member];
    [self makeGETRequestToURL:url withData:nil andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

+(void) getTripWithID: (NSString *) tripID withBlock:  (void (^)(NSDictionary *data, NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"trips/%@", tripID];
    [self makeGETRequestToURL:url withData:nil andBlock:^(id data, NSError *error) {
        block(data,error);
    }];
}

+(void) postTripWithDistance: (NSNumber *)distance gasPrice: (NSNumber *) price mpg: (NSNumber *)mpg polyline: (NSString *)polyline includeUser:(BOOL)user description: (NSString *) description andPassengers: (NSMutableArray *) passengers withBlock: (void (^)(NSDictionary *data, NSError *error))block {
    NSString *url = [NSString stringWithFormat:@"trips/createWithPassengers"];
    
    if (!polyline) {
        polyline = @"";
    }
    
    NSNumber *owner = @0; //Does not own the ride
    NSMutableArray *passengerArray = [NSMutableArray new];
    if (![[TripManager sharedManager] car]) {
        double cost;
        if (user) {
            cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue] / (passengers.count + 1);
        } else {
            cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue] / passengers.count;
        }
        for (NSDictionary *passenger in passengers) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[Venmo sharedInstance].session.user.externalId, [passenger objectForKey: @"id"], [NSNumber numberWithDouble:cost], @2, description,nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"status", @"description", nil]];
            [passengerArray addObject:dict];
        }
        owner = @1;
    } else {
        double cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[[TripManager sharedManager].car objectForKey:@"id"], [Venmo sharedInstance].session.user.externalId, [NSNumber numberWithDouble:cost], @2, description, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"status", @"description", nil]];
        [passengerArray addObject:dict];
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:distance, price, mpg, @1, polyline, passengerArray, owner, [Venmo sharedInstance].session.user.displayName, nil] forKeys:[NSArray arrayWithObjects:@"distance", @"gas_price", @"mpg", @"passenger_count", @"polyline", @"trip_memberships", @"is_owner", @"sender_name", nil]];
    
    [self makePOSTRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

+(void) postTripMembershipWithOwner: (NSString *)owner member: (NSString *) member amount: (NSNumber *)amount status: (NSNumber *)status andTrip: (NSString *)trip {
    // Create the URL Request and set it's method and content type.
    NSString *url = @"trip_memberships";
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:owner, member, amount, trip, status, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"trip", @"status", nil]];

    [self makePOSTRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
    }];
}

+(void) updateTripMembershipWithID: (NSString *)membershipID status: (NSNumber *)status  withBlock: (void (^)(NSDictionary *data, NSError *error))block{
    // Create the URL Request and set it's method and content type.
    NSString *url = [NSString stringWithFormat:@"trip_memberships/%@", membershipID];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:status, nil] forKeys:[NSArray arrayWithObjects:@"status", nil]];
    
    [self makePATCHRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        block(data,error);
    }];
}

+(void) updateTripMembershipsWithIDs: (NSArray *)membershipIDs status: (NSNumber *)status  withBlock: (void (^)(NSArray *data, NSError *error))block{
    // Create the URL Request and set it's method and content type.
    NSString *url = [NSString stringWithFormat:@"trip_memberships/updateTheTrips/%@", status];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:membershipIDs,status, nil] forKeys:[NSArray arrayWithObjects:@"trip_membership_ids",@"status", nil]];
    
    [self makePOSTRequestToURL:url withData:data andBlock:^(id data, NSError *error) {
        block(data,error);
    }];
}

+(void) getTripMembershipWithID: (NSString *)membershipID  withBlock: (void (^)(NSDictionary *data, NSError *error))block{
    // Create the URL Request and set it's method and content type.
    NSString *url = [NSString stringWithFormat: @"trip_memberships/%@", membershipID];
    
    [self makeGETRequestToURL:url withData:nil andBlock:^(NSDictionary *data, NSError *error) {
        block(data, error);
    }];
}

#pragma Request Helpers

+ (void) makeGETRequestToURL: (NSString *)urlEndPoint withData: (NSDictionary *)data andBlock: (void (^)(id data, NSError *error))block {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@",URL, urlEndPoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    if (data) {
        NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONReadingMutableContainers error:nil];
        [request setHTTPBody:newProjectJSONData];
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             id jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
             block(jsonDic, connectionError);
             NSLog(@"MY JSON DATA = %@", jsonDic);
         } else if ([data length] == 0 && connectionError == nil) {
             NSLog(@"No data from server.");
             block(nil, connectionError);
         } else {
             NSLog(@"There is one Error.");
             NSLog(@"%@",connectionError);
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Error connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
             block(nil, connectionError);
         }
     }];
}

+ (void) makePATCHRequestToURL: (NSString *)urlEndPoint withData: (NSDictionary *)data andBlock: (void (^)(id data, NSError *error))block {
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@",URL, urlEndPoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PATCH"];
    
    if (data) {
        NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONReadingMutableContainers error:nil];
        [request setHTTPBody:newProjectJSONData];
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             id jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
             block(jsonDic, connectionError);
             NSLog(@"MY JSON DATA = %@", jsonDic);
         } else if ([data length] == 0 && connectionError == nil) {
             NSLog(@"No data from server.");
             block(nil, connectionError);
         } else {
             NSLog(@"There is one Error.");
             NSLog(@"%@",connectionError);
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Error connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
             block(nil, connectionError);
         }
     }];
}

+ (void) makePOSTRequestToURL: (NSString *)urlEndPoint withData: (NSDictionary *)data andBlock: (void (^)(id data, NSError *error))block {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/%@",URL, urlEndPoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    if (data) {
        NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONReadingMutableContainers error:nil];
        [request setHTTPBody:newProjectJSONData];
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             id jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:nil];
             block(jsonDic, connectionError);
             NSLog(@"MY JSON DATA = %@", jsonDic);
         } else if ([data length] == 0 && connectionError == nil) {
             NSLog(@"No data from server.");
             block(nil, connectionError);
         } else {
             NSLog(@"There is one Error.");
             NSLog(@"%@",connectionError);
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Error connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
             block(nil, connectionError);
         }
     }];
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
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"No Gas Stations" message:@"We could not find any gas stations around you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
                block(nil,error);
            }
        } else {
            NSLog(@"There is one Error.");
            NSLog(@"%@",error);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error" message:@"Error connecting to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
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


@end
