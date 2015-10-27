//
//  PassengerTableViewCell.h
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PassengerTableViewCell : UITableViewCell

@property (nonatomic) PFUser *passenger;

@end
