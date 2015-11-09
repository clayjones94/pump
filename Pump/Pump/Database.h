//
//  Database.h
//  Pump
//
//  Created by Clay Jones on 9/3/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Database : NSObject

//+(void) authUserWithVenmoWithBlock:(void (^)(BOOL success))block;
//+ (void)updateAPNSToken;
//+ (void)updateBadgeCount;
//+ (void) logoutUser;
//+(void) postTripWithDistance: (NSNumber *)distance gasPrice: (NSNumber *) price mpg: (NSNumber *)mpg polyline: (NSString *)polyline includeUser:(BOOL)user description: (NSString *) description andPassengers: (NSMutableArray *) passengers withBlock: (void (^)(NSDictionary *data, NSError *error))block;
//+(void) postTripMembershipWithOwner: (NSString *)owner member: (NSString *) member amount: (NSNumber *)amount status: (NSNumber *)status andTrip: (NSString *)trip;
//+(void) getTripOwnershipsWithID: (NSString *) owner andStatus: (NSUInteger) status withBlock: (void (^)(NSArray *data, NSError *error))block;
//+(void) getTripMembershipsWithID: (NSString *) member andStatus: (NSUInteger)status withBlock: (void (^)(NSArray *data, NSError *error))block;
//+(void) getTripWithID: (NSString *) tripID withBlock:  (void (^)(NSDictionary *data, NSError *error))block;
//+(void) updateTripMembershipWithID: (NSString *)membershipID status: (NSNumber *)status  withBlock: (void (^)(NSDictionary *data, NSError *error))block;
//+(void) updateTripMembershipsWithIDs: (NSArray *)membershipIDs status: (NSNumber *)status  withBlock: (void (^)(NSArray *data, NSError *error))block;
//+(void) getTripMembershipWithID: (NSString *)membershipID  withBlock: (void (^)(NSDictionary *data, NSError *error))block;
//+(void) getCompleteTripMembershipsWithID: (NSString *) member withBlock: (void (^)(NSArray *data, NSError *error))block;
+(void) retrieveVenmoFriendsWithLimit: (NSNumber *) limit withBlock:(void (^)(NSArray *data, NSError *error))block;
+(void) retrieveVenmoFriendWithID:(NSString *)friendID withBlock:(void (^)(NSDictionary *data, NSError *error))block;
+(void) retrieveLocalGasPriceForType:(GasType)type withBlock:(void (^)(NSArray *data, NSError *error))block;
+(void) getCarYearswithBlock:(void (^)(NSData *data, NSError *error))block;
+(void) getCarMakesFromYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block;
+(void) getCarModelsFromMake:(NSString *) make andYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block;
+(void) getCarFromModel: (NSString *) model make:(NSString *) make andYear: (NSString *) year withBlock:(void (^)(NSData *data, NSError *error))block;
+(void) getCarFromID: (NSString *) carID withBlock:(void (^)(NSData *data, NSError *error))block;
+(void) getMileageFromID: (NSString *) carID withBlock:(void (^)(NSData *data, NSError *error))block;
@end
