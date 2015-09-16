//
//  UserManager.m
//  Pump
//
//  Created by Clay Jones on 9/6/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "UserManager.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>

@implementation UserManager {
    
}

@synthesize friends = _friends;
@synthesize venmoID = _venmoID;

+ (UserManager *)sharedManager {
    static UserManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if (self == [super init]) {
        [self updateFriendsWithBlock:^(BOOL updated) {
            
        }];
    }
    return self;
}

-(void) updateFriendsWithBlock: (void (^)(BOOL updated))block{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/me?access_token=%@", [[[Venmo sharedInstance]session] accessToken]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *dataDict = [[responseDict objectForKey:@"data"] objectForKey:@"user"];
        NSNumber *numberOfFriends = [dataDict valueForKey:@"friends_count"];
        if (_friends.count != [numberOfFriends doubleValue]) {
            [Database retrieveVenmoFriendsWithLimit:@30 withBlock:^(NSArray *data){
                _friends = data;
                block(YES);
            }];
        } else {
            block(NO);
        }
    }];
    
    [task resume];
}

@end
