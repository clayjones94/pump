//
//  BorrowTripViewController.h
//  Pump
//
//  Created by Clay Jones on 10/24/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VENTokenField/VENTokenField.h>
#import "UserManager.h"

@class SearchUserView;

@protocol BorrowTripViewControllerDelegate <NSObject>
@optional
- (void) borrowTripViewControllerDidSelectUser: (NSDictionary *)user;
@end

@interface BorrowTripViewController : UIViewController<VENTokenFieldDataSource, VENTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property id <BorrowTripViewControllerDelegate> delegate;
@property (nonatomic) VENTokenField *tokenField;
@property (nonatomic) NSArray *friends;
@property (nonatomic) NSMutableArray *selectedFriends;
@end
