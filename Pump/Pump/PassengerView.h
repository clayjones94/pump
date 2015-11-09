//
//  PassengerView.h
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class PassengerView;

@protocol PassengerViewDelegate <NSObject>
@optional
- (void) passengerView: (PassengerView *)view didSelectCellAtIndexPath: (NSIndexPath *)index;
@end

@interface PassengerView : UIView <UITableViewDataSource, UITableViewDelegate>

@property id <PassengerViewDelegate> delegate;

@property (nonatomic) CGFloat currentHeight;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *statuses;

- (void) updatePaymentStatus: (PaymentStatus) status Passenger: (id)passenger atIndex:(NSUInteger) index error: (NSError *) error;

@end
