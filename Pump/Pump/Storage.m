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

- (void) updatePendingTripMembshipsWithBlock: (void (^)(NSArray *data))block {
    [Database getTripMembershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data) {
        _pendingTripMemberships = [NSMutableArray arrayWithArray: data];
        block(data);
    }];
}

- (void) updatePendingTripOwnershipsWithBlock: (void (^)(NSArray *data))block {
    [Database getTripOwnershipsWithID: [Venmo sharedInstance].session.user.externalId andStatus:0 withBlock:^(NSArray *data) {
        _pendingTripOwnerships = [NSMutableArray arrayWithArray: data];
        block(data);
    }];
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
    for (NSDictionary *tripMemberhips in _pendingTripMemberships) {
        if ([[tripMemberhips objectForKey:@"id"]integerValue] == [membershipID integerValue]) {
            [tripMemberhips setValue:status forKey:@"status"];
        }
    }
}

- (void) updateOwnershipStatus: (NSNumber *) status ForID: (NSNumber *) membershipID {
    for (NSDictionary *tripMemberhips in _pendingTripOwnerships) {
        if ([[tripMemberhips objectForKey:@"id"]integerValue] == [membershipID integerValue]) {
            [tripMemberhips setValue:status forKey:@"status"];
        }
    }
}


@end
