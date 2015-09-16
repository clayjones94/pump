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

@implementation Database

NSString *const URL = @"https://pumpstart.herokuapp.com/";

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

+(void) getTripMembershipsWithID: (NSString *) member withBlock: (void (^)(NSArray *data))block{
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://pump-start.herokuapp.com/trip_memberships/user/%@", member]];
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

+(void) postTripWithDistance: (NSNumber *)distance gasPrice: (NSNumber *) price mpg: (NSNumber *)mpg andPassengerCount: (NSNumber *)count withBlock: (void (^)(NSDictionary *data))block {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString:@"https://pump-start.herokuapp.com/trips"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:distance, price, mpg, count, nil] forKeys:[NSArray arrayWithObjects:@"distance", @"gas_price", @"mpg", @"passenger_count", nil]];
    
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

+(void) postTripMembershipWithOwner: (NSString *)owner member: (NSString *) member amount: (NSNumber *)amount andTrip: (NSString *)trip {
    // Create the URL Request and set it's method and content type.
    NSURL *url = [NSURL URLWithString:@"https://pump-start.herokuapp.com/trip_memberships"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    // Create an dictionary of the info for our new project, including the selected images.
    NSMutableDictionary *newProject = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:owner, member, amount, trip, nil] forKeys:[NSArray arrayWithObjects:@"owner", @"member", @"amount", @"trip", nil]];
    
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
