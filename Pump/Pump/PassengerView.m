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
#import <Venmo-iOS-SDK/Venmo.h>
#import <Parse/Parse.h>

@implementation PassengerView {
    CGRect _boundingFrame;
    NSMutableDictionary *_errors;
}

@synthesize currentHeight = _currentHeight;
@synthesize tableView = _tableView;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _boundingFrame = frame;
    _tableView.delegate = self;
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _errors = [[NSMutableDictionary alloc] init];
    
    [self addSubview:_tableView];
    
    return self;
}

- (void) updatePaymentStatus: (PaymentStatus) status Passenger: (id)passenger atIndex:(NSUInteger) index error:(NSError *)error{
    if (status == PAYMENT_PROCESSING) {
        [[TripManager sharedManager].paymentStatuses replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:PAYMENT_SUCCESS]];
    } else {
        [[TripManager sharedManager].paymentStatuses replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:status]];
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    PassengerTableViewCell *cell = [_tableView cellForRowAtIndexPath:path];
    [cell setStatus:status];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PassengerTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Passenger Cell"];
    if (!cell) {
        cell = [[PassengerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Passenger Cell"];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    id passenger;
    
    float cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue];
    
    if ([TripManager sharedManager].car) {
        passenger = [TripManager sharedManager].car;
        [cell setPassenger: passenger];
    } else {
        passenger = [[TripManager sharedManager].passengers objectAtIndex:indexPath.row];
        [cell setPassenger: passenger];
        cost = cost / ([TripManager sharedManager].passengers.count + 1);
    }
    
    [cell setCost:cost];
    
    PaymentStatus status = [[[TripManager sharedManager].paymentStatuses objectAtIndex:indexPath.row] integerValue];;
    if (cell.status != status || !cell.status) {
        [cell setStatus:status];;
    }
//        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[passenger objectForKey:@"profile_picture_url"]]
//                          placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
        return cell;
//    }
//    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rowCount;
    if ([TripManager sharedManager].car) {
        rowCount = 1;
    } else {
        rowCount = [TripManager sharedManager].passengers.count;
    }
    CGFloat height;
    if (rowCount * 50 > _boundingFrame.size.height) {
        height = _boundingFrame.size.height;
        [_tableView setScrollEnabled:YES];
    } else {
        height = rowCount * 50;
        [_tableView setScrollEnabled:NO];
    }
    [_tableView setFrame:CGRectMake(0, 0, _boundingFrame.size.width, height)];
    return rowCount;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //PassengerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate passengerView:self didSelectCellAtIndexPath:indexPath];
    //[cell setStatus:PAYMENT_PROCESSING];
//    if (indexPath.row == [TripManager sharedManager].passengers.count + 1) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Add Passengers" object:nil];
//    }
//    else if (indexPath.row == 0) {
//        if ([[TripManager sharedManager] includeUserAsPassenger]) {
//            [TripManager sharedManager].includeUserAsPassenger = NO;
//        } else {
//            [TripManager sharedManager].includeUserAsPassenger = YES;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [tableView reloadData];
//        });
//    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

@end
