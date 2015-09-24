//
//  Storage.h
//  Pump
//
//  Created by Clay Jones on 9/24/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

@property (nonatomic) NSMutableArray *pendingTripMemberships;
@property (nonatomic) NSMutableArray *pendingTripOwnerships;

+ (Storage *)sharedManager;

- (void) updatePendingTripMembshipsWithBlock: (void (^)(NSArray *data))block;
- (void) updatePendingTripOwnershipsWithBlock: (void (^)(NSArray *data))block;
- (void) updateMembershipStatus: (NSNumber *) status ForID: (NSNumber *) membershipID;
- (void) updateOwnershipStatus: (NSNumber *) status ForID: (NSNumber *) membershipID;
-(NSMutableArray *) ownershipsWithMember: (NSString *) friendID;
-(NSMutableArray *) membershipsWithOwner: (NSString *) friendID;

@end
