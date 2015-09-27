//
//  SearchUserView.h
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VENTokenField/VENTokenField.h>
#import "UserManager.h"

@class SearchUserView;

@protocol SearchUserViewDelegate <NSObject>
@optional
- (void) searchView: (SearchUserView *)manager didSelectUser: (NSDictionary *)user;
@end

@interface SearchUserView : UIView<VENTokenFieldDataSource, VENTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property id <SearchUserViewDelegate> delegate;
@property (nonatomic) VENTokenField *tokenField;
@property (nonatomic) NSArray *friends;
@property (nonatomic) NSMutableArray *selectedFriends;

@end
