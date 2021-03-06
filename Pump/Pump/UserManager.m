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

#define MAX_RECENTS 60

@implementation UserManager {
    
}

@synthesize friends = _friends;
@synthesize venmoID = _venmoID;
@synthesize recents = _recents;
@synthesize memberships = _memberships;
@synthesize ownerships = _ownerships;
@synthesize loggedIn = _loggedIn;
@synthesize contactStore = _contactStore;
@synthesize phoneNumbers = _phoneNumbers;


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
        _contactStore = [CNContactStore new];
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
            [_contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {

            }];
        }
    }
    return self;
}

-(void) getVenmoFriendsWithBlock: (void (^)(NSArray *friends, NSError *error))block{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.venmo.com/v1/me?access_token=%@", [[[Venmo sharedInstance]session] accessToken]]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *dataDict = [[responseDict objectForKey:@"data"] objectForKey:@"user"];
        NSNumber *numberOfFriends = [dataDict valueForKey:@"friends_count"];
        [Database retrieveVenmoFriendsWithLimit:numberOfFriends withBlock:^(NSArray *data, NSError *error){
            block(data, error);
            //[self updateFriendsDict];
        }];
    }];
    
    [task resume];
}

//-(void) updateOwnershipsWithBlock: (void (^)(NSArray *ownerships, NSError *error))block {
//    [Database getTripOwnershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data, NSError *error) {
//        _ownerships = data;
//        block(data, nil);
//    }];
//}
//
//-(void) updateMembershipsWithBlock: (void (^)(NSArray *memberships, NSError *error))block{
//    [Database getTripMembershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data, NSError *error) {
//        _memberships = data;
//        block(data, nil);
//    }];
//}

-(void) addFriendToRecents:(NSDictionary *)friendDict {
    if (![_recents containsObject:friendDict]) {
        [_recents insertObject:friendDict atIndex:0];
        
        if (_recents.count > MAX_RECENTS) {
            [_recents removeLastObject];
        }
    } else {
        [_recents removeObject:friendDict];
        [_recents insertObject:friendDict atIndex:0];
    }
}

- (NSDictionary *)friendForVenmoID: (NSString *)venID {
    for (NSDictionary *friend in _recents) {
        if ([[friend objectForKey:@"id"] isEqualToString:venID]) {
            return friend;
        }
    }
    return nil;
}

-(void)logoutOfManager {
    _venmoID = nil;
    [_recents removeAllObjects];
    _memberships = nil;
    _ownerships = nil;
}

-(void) loginWithBlock:(void (^)(BOOL loggedIn))block {
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments,
                                                 VENPermissionAccessProfile,
                                                 VENPermissionAccessBalance,
                                                 VENPermissionAccessEmail,
                                                 VENPermissionAccessPhone,
                                                 VENPermissionAccessFriends] withCompletionHandler:^(BOOL success, NSError *error) {
                                                     if (success) {
                                                         block(YES);
                                                     } else {
                                                         block(NO);
                                                     }
                                                 }];
}

@end
