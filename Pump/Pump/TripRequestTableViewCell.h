//
//  TripRequestTableViewCell.h
//  Pump
//
//  Created by Clay Jones on 9/23/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripRequestTableViewCell : UITableViewCell

@property (nonatomic) UILabel *amountLabel;
@property (nonatomic) NSString *memberID;
@property (nonatomic) BOOL isRequest;

-(void) setCellRequestedOrIgnored;
-(void) setCellPending;
@end
