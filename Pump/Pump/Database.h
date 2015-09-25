//
//  Database.h
//  Pump
//
//  Created by Clay Jones on 9/3/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Database : NSObject

+(void) createUserWithMPG: (NSNumber *)mpg forVenmoID: (NSString *)ven_id withBlock: (void (^)(NSDictionary *data))block ;
+(void) retrieveVenmoFriendsWithLimit: (NSNumber *) limit withBlock:(void (^)(NSArray *data))block;
+(void) sendRequestType: (NSString *)type toURL: (NSString *) urlStr withData: (NSDictionary *) data withBlock:(void (^)(NSDictionary *data))block;
+(void) postTripWithDistance: (NSNumber *)distance gasPrice: (NSNumber *) price mpg: (NSNumber *)mpg polyline: (NSString *)polyline andPassengers: (NSMutableArray *) passengers withBlock: (void (^)(NSDictionary *data, NSError *error))block;
+(void) postTripMembershipWithOwner: (NSString *)owner member: (NSString *) member amount: (NSNumber *)amount status: (NSNumber *)status andTrip: (NSString *)trip;
+(void) getTripOwnershipsWithID: (NSString *) owner andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data))block;
+(void) getTripMembershipsWithID: (NSString *) member andStatus: (NSUInteger)status withBlock: (void (^)(NSArray *data))block;
+(void) getTripWithID: (NSString *) tripID withBlock:  (void (^)(NSDictionary *data))block;
+(void) updateTripMembershipWithID: (NSString *)membershipID status: (NSNumber *)status  withBlock: (void (^)(NSDictionary *data))block;
+(void) updateTripMembershipsWithIDs: (NSArray *)membershipIDs status: (NSNumber *)status  withBlock: (void (^)(NSArray *data))block;
+(void) getTripMembershipWithID: (NSString *)membershipID  withBlock: (void (^)(NSDictionary *data))block;
+(void) getCompleteTripMembershipsWithID: (NSString *) member withBlock: (void (^)(NSArray *data))block;
@end