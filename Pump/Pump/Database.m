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

@implementation Database

NSString *const URL = @"https://pump-start.herokuapp.com";
//NSString *const URL = @"http://localhost:5432";

+(void) createUserWithMPG: (NSNumber *) mpg forVenmoID: (NSString *)ven_id withBlock: (void (^)(NSDictionary *data))block {
    
    NSDictionary *data = @{
        @"mpg": mpg,
        @"venmo_id": ven_id,
    };
    //[self sendRequestType: @"POST" toURL:@"users/" withData: data withBlock: block];
}

+(NSArray *) getFriendsFromCD {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: @"Friend" inManagedObjectContext:appDelegate.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    return [[appDelegate managedObjectContext] executeFetchRequest:request error:&error];
}

+(void) retrieveVenmoFriendsWithLimit: (NSNumber *) limit withBlock:(void (^)(NSArray *data))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/users/%@/friends?access_token=%@&limit=%ld", [[[Venmo sharedInstance] session] user].externalId,[[[Venmo sharedInstance]session] accessToken], (long)[limit integerValue]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *friendArray = [dataDict objectForKey:@"data"];
        block(friendArray);
    }];
    
    [task resume];
}

+(void) retrieveVenmoFriendWithID:(NSString *)friendID withBlock:(void (^)(NSDictionary *data))block {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/users/%@?access_token=%@", friendID,[[[Venmo sharedInstance]session] accessToken]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *friend = [dataDict objectForKey:@"data"];
        block(friend);
    }];
    
    [task resume];
}

+(void) getTripOwnershipsWithID: (NSString *) owner andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships/owner/%@/status/%lu", URL, owner, (unsigned long)status]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSArray *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             block(jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             
             NSLog(@"There is one Error.");
             
         }
     }];
}


+(void) getTripMembershipsWithID: (NSString *) member andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships/member/%@/status/%lu", URL, member, (unsigned long)status]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSArray *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             block(jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             
             NSLog(@"There is one Error.");
             
         }
     }];
}

+(void) getCompleteTripMembershipsWithID: (NSString *) member withBlock: (void (^)(NSArray *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships/completeForUser/%@", URL, member]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    

    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSArray *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             block(jsonDic);
             
         } else if ([data length] == 0 && connectionError == nil) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             
             NSLog(@"There is one Error.");
             
         }
     }];
}

+(void) getTripWithID: (NSString *) tripID withBlock:  (void (^)(NSDictionary *data))block {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trips/%@",URL, tripID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             block(jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             
             NSLog(@"There is one Error.");
             
         }
     }];
}

+(void) postTripWithDistance: (NSNumber *)distance gasPrice: (NSNumber *) price mpg: (NSNumber *)mpg polyline: (NSString *)polyline includeUser:(BOOL)user andPassengers: (NSMutableArray *) passengers withBlock: (void (^)(NSDictionary *data, NSError *error))block {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trips/createWithPassengers",URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    if (!polyline) {
        polyline = @"";
    }
    
    NSMutableArray *passengerArray = [NSMutableArray new];
    if (![[TripManager sharedManager] car]) {
        double cost;
        if (user) {
            cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue] / (passengers.count + 1);
        } else {
            cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue] / passengers.count;
        }
        for (NSDictionary *passenger in passengers) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[Venmo sharedInstance].session.user.externalId, [passenger objectForKey: @"id"], [NSNumber numberWithDouble:cost], @0, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"status", nil]];
            [passengerArray addObject:dict];
        }
    } else {
        double cost = [distance doubleValue] / [mpg doubleValue] * [price doubleValue];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[[TripManager sharedManager].car objectForKey:@"id"], [Venmo sharedInstance].session.user.externalId, [NSNumber numberWithDouble:cost], @0, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"status", nil]];
        [passengerArray addObject:dict];
    }
    
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:distance, price, mpg, @1, polyline, passengerArray, nil] forKeys:[NSArray arrayWithObjects:@"distance", @"gas_price", @"mpg", @"passenger_count", @"polyline", @"trip_memberships", nil]];
    
    // Convert our dictionary to JSON and NSData
    NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:newProject options:NSJSONReadingMutableContainers error:nil];
    
    // Assign the request body
    [request setHTTPBody:newProjectJSONData];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {

             NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             block(jsonDic, connectionError);
             
         } else {
             block(nil, connectionError);
         }
     }];
}

+(void) postTripMembershipWithOwner: (NSString *)owner member: (NSString *) member amount: (NSNumber *)amount status: (NSNumber *)status andTrip: (NSString *)trip {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships",URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:owner, member, amount, trip, status, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"trip", @"status", nil]];
    
    // Convert our dictionary to JSON and NSData
    NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:newProject options:NSJSONReadingMutableContainers error:nil];
    
    // Assign the request body
    [request setHTTPBody:newProjectJSONData];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             NSLog(@"There is one Error.");
         }
     }];
}

+(void) updateTripMembershipWithID: (NSString *)membershipID status: (NSNumber *)status  withBlock: (void (^)(NSDictionary *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships/%@",URL, membershipID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PATCH"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:status, nil] forKeys:[NSArray arrayWithObjects:@"status", nil]];
    
    // Convert our dictionary to JSON and NSData
    NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:newProject options:NSJSONReadingMutableContainers error:nil];
    
    // Assign the request body
    [request setHTTPBody:newProjectJSONData];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             block(jsonDic);
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             NSLog(@"There is one Error.");
         }
     }];
}

+(void) updateTripMembershipsWithIDs: (NSArray *)membershipIDs status: (NSNumber *)status  withBlock: (void (^)(NSArray *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/trip_memberships/updateTheTrips/%@",URL, status]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:membershipIDs,status, nil] forKeys:[NSArray arrayWithObjects:@"trip_membership_ids",@"status", nil]];
    
    // Convert our dictionary to JSON and NSData
    NSData *newProjectJSONData = [NSJSONSerialization dataWithJSONObject:newProject options:NSJSONReadingMutableContainers error:nil];
    
    // Assign the request body
    [request setHTTPBody:newProjectJSONData];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSArray *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             block(jsonDic);
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             NSLog(@"There is one Error.");
         }
     }];
}

+(void) getTripMembershipWithID: (NSString *)membershipID  withBlock: (void (^)(NSDictionary *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/trip_memberships/%@", URL, membershipID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    // Init operation queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Connect server.
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         
         if ([data length] > 0 && connectionError == nil) {
             
             NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingAllowFragments
                                                                              error:nil];
             // Debug:
             NSLog(@"MY JSON DATA = %@", jsonDic);
             
         } else if ([data length] == 0) { // No data from server.
             
             NSLog(@"No data from server.");
             
         } else { // There is one Error.
             NSLog(@"There is one Error.");
         }
     }];
}


+(void) sendRequestType: (NSString *)type toURL: (NSString *) urlStr withData: (NSDictionary *) data withBlock:(void (^)(NSDictionary *data))block {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [URL stringByAppendingString:urlStr]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    NSError *error;
    request.HTTPMethod = type;
    request.HTTPBody = [NSJSONSerialization
                        dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        block(dataDict);
    }];
    
    [task resume];
}

@end
