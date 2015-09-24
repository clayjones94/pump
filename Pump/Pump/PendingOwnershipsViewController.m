//
//  PendingOwnershipsViewController.m
//  Pump
//
//  Created by Clay Jones on 9/18/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PendingOwnershipsViewController.h"
#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "TripsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserManager.h"
#import "Storage.h"

@interface PendingOwnershipsViewController ()

@end

@implementation PendingOwnershipsViewController {
    UITableView *_tableview;
    NSMutableDictionary *_friends;
    NSMutableArray *_friendArray;
    UIRefreshControl *_refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.frame];
    [_tableview setDelegate:self];
    [_tableview setDataSource:self];
    self.view = _tableview;
    
    _friends = [NSMutableDictionary new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [_tableview addSubview:_refreshControl];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void) refresh {
    _tableview.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    [_refreshControl beginRefreshing];
    [self refresh:_refreshControl];
}

-(void) refresh: (UIRefreshControl *) refreshControl {
     [[Storage sharedManager] updatePendingTripOwnershipsWithBlock:^(NSArray *data) {
        _friends = [NSMutableDictionary new];
        [self filterOwnerships];
        [[UserManager sharedManager] updateFriendsWithBlock:^(BOOL updated) {
            [refreshControl endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableview reloadData];
            });
        }];
    }];
}

-(void) filterOwnerships {
    _friends = [NSMutableDictionary new];
    for (NSDictionary *ownership in [[Storage sharedManager] pendingTripOwnerships]) {
        if ([_friends objectForKey: [ownership objectForKey: @"member"]]) {
            [[_friends objectForKey: [ownership objectForKey: @"member"]] addObject:ownership];
        } else {
            [_friends setObject:[NSMutableArray arrayWithObject:ownership] forKey:[ownership objectForKey: @"member"]];
        }
    }
    _friendArray = [NSMutableArray new];
    for (NSString *key in _friends) {
        [_friendArray addObject: [_friends objectForKey: key]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileFriendTableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    if (!cell) {
        cell = [[ProfileFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Friend Cell"];
    }
    NSMutableArray *membershipArr = [_friendArray objectAtIndex:indexPath.row];
    NSDictionary *membership = [membershipArr objectAtIndex:0];
    NSDictionary *friend = [[[UserManager sharedManager] friendsDict] objectForKey:[membership objectForKey: @"member"]];
    if (friend) {
        [cell setFriendName:[friend objectForKey: @"display_name"]];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"profile_picture_url"]]
                          placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
    } else {
        [cell setFriendName:@"*missing name*"];
    }
    [cell setNumberOfRides:[NSNumber numberWithInteger: membershipArr.count]];
    
    double amount = 0;
    NSMutableArray *membershipIDs = [NSMutableArray new];
    for (NSDictionary *membership in membershipArr) {
        amount += [[membership objectForKey:@"amount"] doubleValue];
        [membershipIDs addObject:[membership objectForKey:@"id"]];
    }
    
    [cell setMembershipIDs:membershipIDs];
    [cell setIsRequest:YES];
    [cell setAmountOwed: [NSNumber numberWithDouble: amount]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    NSMutableArray *membershipArr = [_friendArray objectAtIndex:indexPath.row];
    
    TripsViewController *vc = [TripsViewController new];
    [vc setTrips:membershipArr];
    [vc setIsRequests:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of sections.
    [self filterOwnerships];
    if (_friends.count > 0) {
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        return _friends.count;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.attributedText = [Utils defaultString:@"No Pending Requests" size:16 color:[UIColor blackColor]];
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
    return 100;
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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

