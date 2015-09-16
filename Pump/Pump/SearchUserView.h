//
//  SearchUserView.h
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VENTokenField/VENTokenField.h>

@interface SearchUserView : UIView<VENTokenFieldDataSource, VENTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) VENTokenField *tokenField;
@property (nonatomic) NSArray *friends;
@property (nonatomic) NSMutableArray *selectedFriends;

@end
