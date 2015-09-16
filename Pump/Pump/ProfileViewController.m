//
//  ProfileViewController.m
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController {
    UITableView *_tableview;
    NSArray *_memberships;
    NSMutableDictionary *_friends;
    NSMutableArray *_friendArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    _memberships = [NSArray new];
    _friends = [NSMutableDictionary new];
    
    [Database getTripMembershipsWithID: [Venmo sharedInstance].session.user.externalId withBlock:^(NSArray *data) {
        _memberships = data;
        [self filterMemberships];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableview reloadData];
        });
    }];
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.frame];
    [_tableview setDelegate:self];
    [_tableview setDataSource:self];
    self.view = _tableview;
}

-(void) filterMemberships {
    for (NSDictionary *membership in _memberships) {
        if ([_friends objectForKey: [membership objectForKey: @"member"]]) {
            [[_friends objectForKey: [membership objectForKey: @"member"]] addObject:membership];
        } else {
            [_friends setObject:[NSMutableArray arrayWithObject:membership] forKey:[membership objectForKey: @"member"]];
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
        cell = [[ProfileFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Friend Cell"];
    }
    NSMutableArray *friendArr = [_friendArray objectAtIndex:indexPath.row];
    NSDictionary *friend = [friendArr objectAtIndex:0];
    [cell setFriendName:[friend objectForKey:@"member"]];
    [cell setNumberOfRides:[NSNumber numberWithInteger: friendArr.count]];
    
    double amount = 0;
    for (NSDictionary *membership in friendArr) {
        amount += [[membership objectForKey:@"amount"] doubleValue];
    }
    
    [cell setAmountOwed: [NSNumber numberWithDouble: amount]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friends.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
