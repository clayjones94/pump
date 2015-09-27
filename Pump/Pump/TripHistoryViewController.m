//
//  TripHistoryViewController.m
//  Pump
//
//  Created by Clay Jones on 9/21/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripHistoryViewController.h"
#import "Database.h"
#import "Utils.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "UserManager.h"
#import "TripInfoViewController.h"

@interface TripHistoryViewController ()

@end

@implementation TripHistoryViewController {
    UITableView *_tableview;
    NSArray *_tripMemberships;
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
//    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.frame];
    [_tableview setDelegate:self];
    [_tableview setDataSource:self];
    self.view = _tableview;
    
    _tripMemberships = [NSArray new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:_refreshControl];
    
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"History"];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

-(void) refresh {
    _tableview.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    [_refreshControl beginRefreshing];
    [self refresh:_refreshControl];
}

-(void) refresh: (UIRefreshControl *) refreshControl {
    [Database getCompleteTripMembershipsWithID:[Venmo sharedInstance].session.user.externalId withBlock:^(NSArray *data) {
        _tripMemberships = data;
            [refreshControl endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableview reloadData];
            });
    }];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Friend Cell"];
    }
    
    NSDictionary *membership = [_tripMemberships objectAtIndex: indexPath.row];
    
    NSMutableAttributedString *title;
    
    NSDictionary *friend = [[UserManager sharedManager] friendForVenmoID:[membership objectForKey: @"member"]];
    if (!friend) {
        [Database retrieveVenmoFriendWithID:[membership objectForKey: @"member"] withBlock:^(NSDictionary *data) {
            
            if ([UserManager sharedManager].recents.count < 60 && ![[UserManager sharedManager].recents containsObject:data]) {
                [[UserManager sharedManager].recents addObject:data];
            }
            [tableView reloadData];
        }];
    }
    if ([[membership objectForKey:@"owner"] isEqualToString: [Venmo sharedInstance].session.user.externalId]) {
        if ([[membership objectForKey:@"status"] intValue] == 1) {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"Request" size:16 color:[Utils defaultColor]]];
        } else {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"Ignore" size:16 color:[UIColor grayColor]]];
        }
    } else {
        friend = [[UserManager sharedManager] friendForVenmoID:[membership objectForKey: @"owner"]];
        if ([[membership objectForKey:@"status"] intValue] == 1) {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"Pay" size:16 color:[UIColor redColor]]];
        } else {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"Ignore" size:16 color:[UIColor grayColor]]];
        }
    }
    [title appendAttributedString:[Utils defaultString:@"\rTrip with " size:12 color:[UIColor blackColor]]];
    [title appendAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@ was $%.2f.", [friend objectForKey:@"display_name"],[[membership objectForKey:@"amount"] doubleValue]] size:12 color:[UIColor blackColor]]];
    
    [cell.textLabel setAttributedText: title];
    cell.textLabel.numberOfLines = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString *dateStr = [membership objectForKey:@"updated_at"];
    
    NSDate *date = [dateFormatter dateFromString: dateStr];
    
    NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:date];
    NSString *timeStr = [NSString stringWithFormat:@"%.0fs ago", secondsBetween];
    int numberOfMinutes = secondsBetween / 60;
    if (numberOfMinutes > 0) {
        timeStr = [NSString stringWithFormat:@"%dm ago", numberOfMinutes];
    }
    int numberOfHours = numberOfMinutes / 60;
    if (numberOfHours > 0) {
        timeStr = [NSString stringWithFormat:@"%dh ago", numberOfHours];
    }
    int numberOfDays = numberOfHours / 24;
    if (numberOfDays > 0) {
        timeStr = [NSString stringWithFormat:@"%dd ago", numberOfDays];
    }
    int numberOfWeeks = numberOfDays / 7;
    if (numberOfWeeks > 0) {
        timeStr = [NSString stringWithFormat:@"%dw ago", numberOfWeeks];
    }
    cell.detailTextLabel.attributedText = [Utils defaultString:timeStr size:12 color:[UIColor lightGrayColor]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    TripInfoViewController *vc = [[TripInfoViewController alloc] init];
    
    vc.tripMembership = [_tripMemberships objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSMutableArray *ids = [NSMutableArray new];
//    for (NSDictionary *dict in _tripMemberships) {
//        [Database updateTripMembershipWithID:[dict objectForKey:@"id"] status:@0 withBlock:^(NSDictionary *data) {
//        }];
//    }
    // Return the number of sections.
    if (_tripMemberships.count > 0) {
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        return _tripMemberships.count;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.attributedText = [Utils defaultString:@"No Trip History" size:16 color:[UIColor blackColor]];
        messageLabel.textColor = [UIColor lightGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        _tableview.backgroundView = messageLabel;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
