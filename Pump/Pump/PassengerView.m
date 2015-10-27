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
#import <SDWebImage/UIImageView+WebCache.h>
#import <Venmo-iOS-SDK/Venmo.h>
#import <Parse/Parse.h>

@implementation PassengerView {
    CGRect _boundingFrame;
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
    
    [self addSubview:_tableView];
    
    return self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0 || indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"User Cell"];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"User Cell"];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(2.5, 2.5, _boundingFrame.size.width - 5, 35)];
        [backgroundView setBackgroundColor:[Utils defaultLightColor]];
        [cell addSubview:backgroundView];
        [cell sendSubviewToBack:backgroundView];
        if (indexPath.row == 0) {
            NSString *name = @"Include me";
            if ([[Venmo sharedInstance] isSessionValid]) {
                name = [Venmo sharedInstance].session.user.displayName;
                //[cell.imageView sd_setImageWithURL:[NSURL URLWithString:[Venmo sharedInstance].session.user.profileImageUrl]
                                  //placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
            }
            if ([TripManager sharedManager].includeUserAsPassenger) {
                float cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count + 1);
                cell.textLabel.attributedText = [Utils defaultString:name size:12 color:[UIColor whiteColor]];
                NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"$%.2f",cost] size:12 color:[UIColor whiteColor]];
                [cell.detailTextLabel setAttributedText: costString];
            } else {
                cell.textLabel.attributedText = [Utils defaultString:name size:12 color:[UIColor darkGrayColor]];
                cell.detailTextLabel.attributedText = [Utils defaultString:@"$0.00" size:12 color:[UIColor darkGrayColor]];
            }
            return cell;
        } else {
            cell.textLabel.attributedText = [Utils defaultString:@"Add Passengers..." size:12 color:[UIColor whiteColor]];
            cell.detailTextLabel.text = @" ";
        }
    } else {
        PassengerTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Passenger Cell"];
        if (!cell) {
            cell = [[PassengerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Passenger Cell"];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(2.5, 2.5, _boundingFrame.size.width - 5, 35)];
        [backgroundView setBackgroundColor:[Utils defaultLightColor]];
        [cell addSubview:backgroundView];
        [cell sendSubviewToBack:backgroundView];
        PFUser *passenger = [[TripManager sharedManager].passengers objectAtIndex:indexPath.row-1];
        [cell setPassenger: passenger];
        
        float cost;
        if ([[TripManager sharedManager] includeUserAsPassenger]) {
            cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count + 1);
        } else {
            cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count);
        }
        [cell.detailTextLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"$%.2f",cost] size:12 color:[UIColor whiteColor]]];
        
//        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[passenger objectForKey:@"profile_picture_url"]]
//                          placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
        return cell;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        return NO;
    }
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0 && indexPath.row != [TripManager sharedManager].passengers.count + 1) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[TripManager sharedManager].passengers removeObjectAtIndex:indexPath.row-1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Delete Passengers" object:nil];
    [_tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rowCount = [TripManager sharedManager].passengers.count + 2;
    CGFloat height;
    if (rowCount * 40 > _boundingFrame.size.height) {
        height = _boundingFrame.size.height;
        [_tableView setScrollEnabled:YES];
    } else {
        height = rowCount * 40;
        [_tableView setScrollEnabled:NO];
    }
    [_tableView setFrame:CGRectMake(0, 0, _boundingFrame.size.width, height)];
    return rowCount;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    if (indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Add Passengers" object:nil];
    } else if (indexPath.row == 0) {
        if ([[TripManager sharedManager] includeUserAsPassenger]) {
            [TripManager sharedManager].includeUserAsPassenger = NO;
        } else {
            [TripManager sharedManager].includeUserAsPassenger = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

@end
