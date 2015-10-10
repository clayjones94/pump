//
//  TripsViewController.m
//  Pump
//
//  Created by Clay Jones on 9/16/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripsViewController.h"
#import "Utils.h"
#import "TripInfoViewController.h"
#import "Database.h"
#import "TripRequestTableViewCell.h"
#import "Storage.h"

@interface TripsViewController ()

@end

@implementation TripsViewController {
    UITableView *_tableView;
    NSArray *_trips;
    UIRefreshControl *_refreshControl;
}

@synthesize isRequests = _isRequests;
@synthesize friendID = _friendID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self refresh];
}

-(void) refresh {
    _tableView.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    [_refreshControl beginRefreshing];
    [self refresh:_refreshControl];
}

-(void) refresh: (UIRefreshControl *) refreshControl {
    if (_isRequests) {
        [[Storage sharedManager] updatePendingTripOwnershipsWithBlock:^(NSArray *data, NSError *error) {
            _trips = [[Storage sharedManager] ownershipsWithMember:_friendID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [_refreshControl endRefreshing];
            });
        }];
    } else {
        [[Storage sharedManager] updatePendingTripMembshipsWithBlock:^(NSArray *data, NSError *error) {
            _trips = [[Storage sharedManager] membershipsWithOwner:_friendID];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [_refreshControl endRefreshing];
            });
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"Trips"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Trip"];
    if (!cell) {
        cell = [[TripRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Trip"];
    }
    NSDictionary *trip = [_trips objectAtIndex:indexPath.row];
    [cell.amountLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"$%.2f", [[trip objectForKey:@"amount"] floatValue]] size:18 color:[UIColor darkGrayColor]]];
    [cell setDescription:[trip objectForKey:@"description"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString *dateStr = [trip objectForKey:@"created_at"];
    
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
    
    [cell setIsRequest:_isRequests];
    
    cell.memberID = [trip objectForKey:@"id"];
    
    if ([[trip objectForKey:@"status"] integerValue] != 0) {
        [cell setCellRequestedOrIgnored];
    } else {
        [cell setCellPending];
    }
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    TripInfoViewController *vc = [[TripInfoViewController alloc] init];
    
    vc.tripMembership = [_trips objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *trip = [_trips objectAtIndex:indexPath.row];
    NSString *str = [trip objectForKey:@"description"]; // filling text in label
    CGSize maximumSize = CGSizeMake(150, 100); // change width and height to your requirement
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, [UIColor whiteColor]]
                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
    
    CGRect labelRect = [str boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attrsDictionary context:nil];
                     
    return (10+labelRect.size.height+50);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _trips.count;
}

-(void)setTrips:(NSArray *)trips {
    _trips = trips;
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFriendID:(NSString *)friendID {
    _friendID = friendID;
    if (_isRequests) {
        _trips = [[Storage sharedManager] ownershipsWithMember:friendID];
    } else {
        _trips = [[Storage sharedManager] membershipsWithOwner:friendID];
    }
    [_tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
