//
//  PendingMembershipsViewController.m
//  Pump
//
//  Created by Clay Jones on 9/18/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PendingMembershipsViewController.h"
#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "TripsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserManager.h"
#import "Storage.h"

@interface PendingMembershipsViewController ()

@end

@implementation PendingMembershipsViewController {
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
    
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"Pending Payments"];
    [self filterMemberships];
    [_tableview reloadData];
}

-(void) refresh {
    _tableview.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    [_refreshControl beginRefreshing];
    [self refresh:_refreshControl];
}

-(void) refresh: (UIRefreshControl *) refreshControl {
    [[Storage sharedManager] updatePendingTripMembshipsWithBlock:^(NSArray *data) {
        _friends = [NSMutableDictionary new];
        [self filterMemberships];
        [[UserManager sharedManager] updateFriendsWithBlock:^(BOOL updated) {
            [refreshControl endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableview reloadData];
            });
        }];
    }];
}

-(void) filterMemberships {
    _friends = [NSMutableDictionary new];
    for (NSDictionary *ownership in [[Storage sharedManager] pendingTripMemberships]) {
        if ([[ownership objectForKey:@"status"] integerValue] == 0) {
            if ([_friends objectForKey: [ownership objectForKey: @"owner"]]) {
                [[_friends objectForKey: [ownership objectForKey: @"owner"]] addObject:ownership];
            } else {
                [_friends setObject:[NSMutableArray arrayWithObject:ownership] forKey:[ownership objectForKey: @"owner"]];
            }
        }
    }
    _friendArray = [NSMutableArray new];
    for (NSString *key in _friends) {
        [_friendArray addObject: [_friends objectForKey: key]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    if (!cell) {
        cell = [[ProfileFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Friend Cell"];
    }
    NSMutableArray *membershipArr = [_friendArray objectAtIndex:indexPath.row];
    NSDictionary *membership = [membershipArr objectAtIndex:0];
    membershipArr = [[Storage sharedManager] membershipsWithOwner:[membership objectForKey: @"owner"]];
    NSDictionary *friend = [[[UserManager sharedManager] friendsDict] objectForKey:[membership objectForKey: @"owner"]];
    if (friend) {
        [cell setFriendName:[friend objectForKey: @"display_name"]];
    } else {
        [cell setFriendName:@"*missing name*"];
    }
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[friend objectForKey:@"profile_picture_url"]]
                      placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
    
    double amount = 0;
    NSMutableArray *membershipIDs = [NSMutableArray new];
    [cell setCellRequestedOrIgnored];
    NSUInteger i = 0;
    for (NSDictionary *membership in membershipArr) {
        if ([[membership objectForKey:@"status"]integerValue] == 0) {
            amount += [[membership objectForKey:@"amount"] doubleValue];
            [membershipIDs addObject:[membership objectForKey:@"id"]];
            [cell setCellPending];
            i++;
        }
    }
    [cell setNumberOfRides: [NSNumber numberWithInteger: i]];
    
    [cell setMembershipIDs:membershipIDs];
    [cell setIsRequest:NO];
    [cell setAmountOwed: [NSNumber numberWithDouble: amount]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    NSMutableArray *membershipArr = [_friendArray objectAtIndex:indexPath.row];
    NSDictionary *membership = [membershipArr objectAtIndex:0];
    
    TripsViewController *vc = [TripsViewController new];
    [vc setIsRequests:NO];
    [vc setFriendID:[membership objectForKey:@"owner"]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self filterMemberships];
    // Return the number of sections.
    if (_friends.count > 0) {
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        return _friends.count;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.attributedText = [Utils defaultString:@"No Pending Payments" size:16 color:[UIColor blackColor]];
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


