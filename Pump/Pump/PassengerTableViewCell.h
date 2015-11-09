//
//  PassengerTableViewCell.h
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Constants.h"

@interface PassengerTableViewCell : UITableViewCell<CAAction>

@property (nonatomic) id passenger;
@property (nonatomic) double cost;

@property (nonatomic) PaymentStatus status;

@end
