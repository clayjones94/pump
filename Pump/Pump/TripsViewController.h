//
//  TripsViewController.h
//  Pump
//
//  Created by Clay Jones on 9/16/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSString *friendID;
@property (nonatomic) BOOL isRequests;

@end
