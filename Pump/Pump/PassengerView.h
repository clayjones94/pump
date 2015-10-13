//
//  PassengerView.h
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassengerView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CGFloat currentHeight;
@property (nonatomic) UITableView *tableView;

@end
