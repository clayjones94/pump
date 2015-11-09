//
//  Storage.m
//  Pump
//
//  Created by Clay Jones on 9/24/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "Storage.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>

@implementation Storage {
    NSMutableArray *_pendingTripMemberships;
    NSMutableArray *_pendingTripOwnerships;
}

+ (Storage *)sharedManager {
    static Storage *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void) updatePendingTripMembshipsWithBlock: (void (^)(NSArray *data, NSError *error))block {
//    [Database getTripMembershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data, NSError *error) {
//        _pendingTripMemberships = [NSMutableArray arrayWithArray: data];
//        block(data, error);
//    }];
}

- (void) updatePendingTripOwnershipsWithBlock: (void (^)(NSArray *data, NSError *error))block {
//    [Database getTripOwnershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data, NSError *error) {
//        _pendingTripOwnerships = [NSMutableArray arrayWithArray: data];
//        block(data, error);
//    }];
}

-(NSMutableArray *) membershipsWithOwner: (NSString *) friendID {
    NSMutableArray *memberships = [NSMutableArray new];
    for (NSDictionary *tripMemberhip in _pendingTripMemberships) {
        if ([[tripMemberhip objectForKey:@"owner"] isEqualToString: friendID]) {
            [memberships addObject: tripMemberhip];
        }
    }
    return memberships;
}

-(NSMutableArray *) ownershipsWithMember: (NSString *) friendID {
    NSMutableArray *memberships = [NSMutableArray new];
    for (NSDictionary *tripMemberhip in _pendingTripOwnerships) {
        if ([[tripMemberhip objectForKey:@"member"] isEqualToString: friendID]) {
            [memberships addObject: tripMemberhip];
        }
    }
    return memberships;
}

- (void) updateMembershipStatus: (NSNumber *) status ForID: (NSNumber *) membershipID {
    for (int i = 0; i < _pendingTripMemberships.count; i++) {
        NSDictionary *tripMembership = [_pendingTripMemberships objectAtIndex:i];
        if ([[tripMembership objectForKey:@"id"]integerValue] == [membershipID integerValue]) {
            NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tripMembership];
            [newDict setValue:status forKey:@"status"];
            [_pendingTripMemberships replaceObjectAtIndex:i withObject:newDict];
        }
    }
}

- (void) updateOwnershipStatus: (NSNumber *) status ForID: (NSNumber *) membershipID {
    //for (NSDictionary *tripMemberhips in _pendingTripOwnerships) {
    for (int i = 0; i < _pendingTripOwnerships.count; i++) {
        NSDictionary *tripMembership = [_pendingTripOwnerships objectAtIndex:i];
        if ([[tripMembership objectForKey:@"id"]integerValue] == [membershipID integerValue]) {
            NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:tripMembership];
            [newDict setValue:status forKey:@"status"];
            [_pendingTripOwnerships replaceObjectAtIndex:i withObject:newDict];
        }
    }
}

-(void) logoutOfManager {
    [_pendingTripMemberships removeAllObjects];
    [_pendingTripOwnerships removeAllObjects];
}


@end
