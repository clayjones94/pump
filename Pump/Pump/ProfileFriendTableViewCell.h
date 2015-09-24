//
//  ProfileFriendTableViewCell.h
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileFriendTableViewCell : UITableViewCell

@property (nonatomic) NSString *friendName;
@property (nonatomic) NSNumber *amountOwed;
@property (nonatomic) NSNumber *numberOfRides;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *friendVenmoID;
@property (nonatomic) NSArray *membershipIDs;
@property (nonatomic) BOOL isRequest;

-(void) setCellPending;

@end
