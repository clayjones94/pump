//
//  Database.m
//  Pump
//
//  Created by Clay Jones on 9/3/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "Database.h"

@implementation Database

NSString *const URL = @"https://pumpstarter.herokuapp.com/";

+(void) createUserWithMPG: (NSNumber *) mpg forVenmoID: (NSString *)ven_id withBlock: (void (^)(NSDictionary *data))block {
    
    NSDictionary *data = @{
        @"mpg": mpg,
        @"venmo_id": ven_id,
    };
    [self sendRequestType: @"POST" toURL:@"users/" withData: data withBlock: block];
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
        NSLog(@"%@", error);
        NSLog(@"%@", data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        block(dataDict);
    }];
    
    [task resume];
}

@end
