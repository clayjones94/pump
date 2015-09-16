//
//  PassengerView.m
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PassengerView.h"
#import "PassengerTableViewCell.h"
#import "TripManager.h"
#import "Utils.h"

@implementation PassengerView {
    UITableView *_tableView;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSubview:_tableView];
    
    return self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0 || indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"User Cell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"User Cell"];
        }
        if (indexPath.row == 0) {
            cell.textLabel.attributedText = [Utils defaultString:@"Me" size:18 color:[UIColor lightGrayColor]];
        } else {
            cell.textLabel.attributedText = [Utils defaultString:@"Add Passengers..." size:18 color:[UIColor lightGrayColor]];
        }
    } else {
        PassengerTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Passenger Cell"];
        if (!cell) {
            cell = [[PassengerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Passenger Cell"];
        }
        [cell setPassenger:[[TripManager sharedManager].passengers objectAtIndex:indexPath.row-1]];
        return cell;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TripManager sharedManager].passengers.count + 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Add Passengers" object:nil];
    }
}

@end
