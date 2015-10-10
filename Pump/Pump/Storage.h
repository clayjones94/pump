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

- (void) updatePendingTripMembshipsWithBlock: (void (^)(NSArray *data, NSError *error))block;
- (void) updatePendingTripOwnershipsWithBlock: (void (^)(NSArray *data, NSError *error))block;
- (void) updateMembershipStatus: (NSNumber *) status ForID: (NSString *) membershipID;
- (void) updateOwnershipStatus: (NSNumber *) status ForID: (NSString *) membershipID;
-(NSMutableArray *) ownershipsWithMember: (NSString *) friendID;
-(NSMutableArray *) membershipsWithOwner: (NSString *) friendID;
-(void)logoutOfManager;

@end
