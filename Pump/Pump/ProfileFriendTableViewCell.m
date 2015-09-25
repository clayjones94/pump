//
//  ProfileFriendTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import "Storage.h"

#define FRAME_HEIGHT 100
#define DESCRIPTION_FONT_SIZE 12

@implementation ProfileFriendTableViewCell {
    UILabel *_nameLabel;
    UILabel *_amountOwedLabel;
    UILabel *_numberOfRidesLabel;
    UIImageView *_imageView;
    UIButton *_ignoreButton;
    UIButton *_requestButton;
    UIButton *_payButton;
}

@synthesize friendName = _friendName;
@synthesize amountOwed = _amountOwed;
@synthesize numberOfRides = _numberOfRides;
@synthesize friendVenmoID = _friendVenmoID;
@synthesize membershipIDs = _membershipIDs;
@synthesize isRequest = _isRequest;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * .25, 15, 0, 0)];
    [self addSubview:_nameLabel];
    
    _amountOwedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 0, 0)];
    [self addSubview:_amountOwedLabel];
    
    _numberOfRidesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * .6, 15, 0, 0)];
    [self addSubview:_numberOfRidesLabel];
    
    _requestButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_requestButton setBackgroundColor:[Utils defaultColor]];
    [_requestButton setFrame:CGRectMake(self.frame.size.width * .5, FRAME_HEIGHT - 50, 70, 30)];
    [_requestButton addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_requestButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Request" size:12 color:[UIColor whiteColor]];
    [_requestButton.layer setCornerRadius:5];
    [_requestButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _payButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_payButton setBackgroundColor:[Utils defaultColor]];
    [_payButton setFrame:CGRectMake(self.frame.size.width * .5, FRAME_HEIGHT - 50, 70, 30)];
    [_payButton addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
    
    titleString = [Utils defaultString:@"Pay" size:12 color:[UIColor whiteColor]];
    [_payButton.layer setCornerRadius:5];
    [_payButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _ignoreButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_ignoreButton setBackgroundColor:[UIColor darkGrayColor]];
    [_ignoreButton setFrame:CGRectMake(self.frame.size.width * .25, FRAME_HEIGHT - 50, 70, 30)];
    [_ignoreButton addTarget:self action:@selector(ignore) forControlEvents:UIControlEventTouchUpInside];
    
    titleString = [Utils defaultString:@"Ignore" size:12 color:[UIColor whiteColor]];
    [_ignoreButton.layer setCornerRadius:5];
    [_ignoreButton setAttributedTitle: titleString forState:UIControlStateNormal];
    [self addSubview:_ignoreButton];
    
    return self;
}

-(void) request {
    for (NSString *memID in _membershipIDs) {
        if (_isRequest) {
            [[Storage sharedManager] updateOwnershipStatus:@1 ForID:memID];
        } else {
            [[Storage sharedManager] updateMembershipStatus:@1 ForID:memID];
        }
    }
    
    [Database updateTripMembershipsWithIDs:_membershipIDs status:@1 withBlock:^(NSArray *data) {
        NSArray *updated = data;
        double cost = 0;
        for (NSDictionary *membership in updated) {
            cost += [[membership objectForKey:@"amount"] doubleValue];
            [[Storage sharedManager] updateMembershipStatus:@1 ForID:[membership objectForKey:@"id"]];
        }
        if (updated.count != _membershipIDs.count) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Request Completed" message:[NSString stringWithFormat:@"%lu out of %lu were processed. %@ was requested $%.2f", (unsigned long)updated.count, (unsigned long)_membershipIDs.count, _friendName, cost] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
        } else if(updated.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Already Completed" message:[NSString stringWithFormat:@"%@ has already completed these requests.", _friendName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
        }
    }];
    [self setCellRequestedOrIgnored];
}

-(void) ignore {
    for (NSString *memID in _membershipIDs) {
        if (_isRequest) {
            [[Storage sharedManager] updateOwnershipStatus:@2 ForID:memID];
        } else {
            [[Storage sharedManager] updateMembershipStatus:@2 ForID:memID];
        }
    }
    [Database updateTripMembershipsWithIDs:_membershipIDs status:@2 withBlock:^(NSArray *data) {
        [self setCellRequestedOrIgnored];
    }];
}

-(void)setIsRequest:(BOOL)isRequest {
    _isRequest = isRequest;
    if (isRequest) {
        [self addSubview:_requestButton];
    } else {
        [self addSubview:_payButton];
    }
}

-(void) setCellRequestedOrIgnored {
    [_ignoreButton setUserInteractionEnabled:NO];
    [_ignoreButton setBackgroundColor:[UIColor lightGrayColor]];
    [_requestButton setUserInteractionEnabled:NO];
    [_requestButton setBackgroundColor:[UIColor lightGrayColor]];
    [_payButton setUserInteractionEnabled:NO];
    [_payButton setBackgroundColor:[UIColor lightGrayColor]];
}

-(void) setCellPending {
    [_ignoreButton setUserInteractionEnabled:YES];
    [_ignoreButton setBackgroundColor:[UIColor darkGrayColor]];
    [_requestButton setUserInteractionEnabled:YES];
    [_requestButton setBackgroundColor:[Utils defaultColor]];
    [_payButton setUserInteractionEnabled:YES];
    [_payButton setBackgroundColor:[Utils defaultColor]];
}

- (void)setFriendName:(NSString *)friendName {
    _friendName = friendName;
    [_nameLabel setAttributedText:[Utils defaultString:_friendName size:18 color:[UIColor blackColor]]];
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(self.frame.size.width * .25, (FRAME_HEIGHT * .23 - _nameLabel.frame.size.height/2), _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
}

- (void)setAmountOwed:(NSNumber *)amountOwed {
    _amountOwed = amountOwed;
    NSMutableAttributedString *description;
    if (_isRequest) {
        description = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:_friendName size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
        
        [description appendAttributedString:[Utils defaultString:@" owes you " size:DESCRIPTION_FONT_SIZE color:[UIColor blackColor]]];
        [description appendAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.2f.", [amountOwed doubleValue]] size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
    } else {
        description = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"You owe " size:DESCRIPTION_FONT_SIZE color:[UIColor blackColor]]];
        [description appendAttributedString:[Utils defaultString:_friendName size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
        [description appendAttributedString:[Utils defaultString:[NSString stringWithFormat:@" $%.2f.", [amountOwed doubleValue]] size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
    }

    [_nameLabel setAttributedText:description];
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(self.frame.size.width * .25, FRAME_HEIGHT * .23 - _nameLabel.frame.size.height/2, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(self.frame.size.width * .125 - 25, FRAME_HEIGHT * .5 - 25,50,50);
}

-(void) setNumberOfRides:(NSNumber *)numberOfRides {
    _numberOfRides = numberOfRides;
    [_numberOfRidesLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%@ trips", numberOfRides] size:12 color:[UIColor lightGrayColor]]];
    if ([numberOfRides intValue] == 1) {
        [_numberOfRidesLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%@ trip", numberOfRides] size:12 color:[UIColor lightGrayColor]]];
    }
    [_numberOfRidesLabel sizeToFit];
    [_numberOfRidesLabel setFrame:CGRectMake(self.frame.size.width * .81, (FRAME_HEIGHT - _numberOfRidesLabel.frame.size.height)/2, _numberOfRidesLabel.frame.size.width, _numberOfRidesLabel.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
