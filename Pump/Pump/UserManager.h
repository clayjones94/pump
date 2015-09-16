//
//  UserManager.h
//  Pump
//
//  Created by Clay Jones on 9/6/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserManager : NSObject

@property (nonatomic) NSArray *friends;
@property (nonatomic) NSString *venmoID;

+ (UserManager *)sharedManager;
-(void) updateFriendsWithBlock: (void (^)(BOOL updated))block;
@end
