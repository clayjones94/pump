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

@implementation PassengerView {
    UITableView *_tableView;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _tableView = [[UITableView alloc] initWithFrame:self.frame];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"User Cell"];
        }
        if (indexPath.row == 0) {
            if ([TripManager sharedManager].includeUserAsPassenger) {
                float cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count + 1);
                cell.textLabel.attributedText = [Utils defaultString:@"Include me" size:12 color:[Utils defaultColor]];
                NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"$%.2f",cost] size:16 color:[Utils defaultColor]];
                [cell.detailTextLabel setAttributedText: costString];
            } else {
                cell.textLabel.attributedText = [Utils defaultString:@"Include me" size:12 color:[UIColor lightGrayColor]];
                cell.detailTextLabel.text = @" ";
            }
            return cell;
        } else {
            cell.textLabel.attributedText = [Utils defaultString:@"Add Passengers..." size:12 color:[UIColor lightGrayColor]];
            cell.detailTextLabel.text = @" ";
        }
    } else {
        PassengerTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Passenger Cell"];
        if (!cell) {
            cell = [[PassengerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Passenger Cell"];
        }
        
        NSDictionary *passenger = [[TripManager sharedManager].passengers objectAtIndex:indexPath.row-1];
        [cell setPassenger: passenger];
        
        float cost;
        if ([[TripManager sharedManager] includeUserAsPassenger]) {
            cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count + 1);
        } else {
            cost = [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue] / ([TripManager sharedManager].passengers.count);
        }
        [cell.detailTextLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"$%.2f",cost] size:16 color:[Utils defaultColor]]];
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[passenger objectForKey:@"profile_picture_url"]]
                          placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
        return cell;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == 0 || indexPath.row == [TripManager sharedManager].passengers.count + 1) {
        return NO;
    }
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath != 0 || indexPath.row == [TripManager sharedManager].passengers.count + 1) {
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
    return [TripManager sharedManager].passengers.count + 2;
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
