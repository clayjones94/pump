//
//  UserManager.h
//  Pump
//
//  Created by Clay Jones on 9/6/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserManager;

@protocol UserManagerDelegate <NSObject>
@optional
- (void) userManager: (UserManager *)manager didUpdateFriends: (NSArray *)friends;
@end

@interface UserManager : NSObject

@property id <UserManagerDelegate> delegate;
@property (nonatomic) NSArray *friends;
@property (nonatomic) NSString *venmoID;
@property (nonatomic) NSMutableArray *recents;
@property (nonatomic) NSArray *memberships;
@property (nonatomic) NSArray *ownerships;
@property (nonatomic) BOOL loggedIn;

+ (UserManager *)sharedManager;
-(void) getVenmoFriendsWithBlock: (void (^)(NSArray *friends, NSError *error))block;
-(void) addFriendToRecents:(NSDictionary *)friendDict;
- (NSDictionary *)friendForVenmoID: (NSString *)venID;
-(void) updateOwnershipsWithBlock: (void (^)(NSArray *ownerships, NSError *error))block;
-(void) updateMembershipsWithBlock: (void (^)(NSArray *memberships, NSError *error))block;
-(void) loginWithBlock:(void (^)(BOOL loggedIn))block;
-(void)logoutOfManager;
@end
