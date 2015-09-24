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

@interface TripsViewController ()

@end

@implementation TripsViewController {
    UITableView *_tableView;
}

@synthesize trips = _trips;
@synthesize isRequests = _isRequests;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
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
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    TripInfoViewController *vc = [[TripInfoViewController alloc] init];
    
    vc.tripMembership = [_trips objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
