//
//  TripRequestTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/23/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "TripRequestTableViewCell.h"
#import "Utils.h"
#import "Database.h"

#define FRAME_HEIGHT 70

@implementation TripRequestTableViewCell {
    UIButton *_ignoreButton;
    UIButton *_requestButton;
    UIButton *_payButton;
}

@synthesize amountLabel = _amountLabel;
@synthesize memberID = _memberID;
@synthesize isRequest = _isRequest;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _amountLabel = [[UILabel alloc] init];
    [_amountLabel setAttributedText:[Utils defaultString:@"$0.00" size:18 color:[UIColor darkGrayColor]]];
    [_amountLabel sizeToFit];
    [_amountLabel setFrame:CGRectMake(10, FRAME_HEIGHT/2 - _amountLabel.frame.size.height/2, _amountLabel.frame.size.width + 20, _amountLabel.frame.size.height)];
    [self addSubview:_amountLabel];
    
    _requestButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_requestButton setBackgroundColor:[Utils defaultColor]];
    [_requestButton setFrame:CGRectMake(self.frame.size.width * .55, FRAME_HEIGHT/2 - 15, self.frame.size.width * .22, 30)];
    [_requestButton addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_requestButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Request" size:11 color:[UIColor whiteColor]];
    [_requestButton.layer setCornerRadius:5];
    [_requestButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _payButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_payButton setBackgroundColor:[Utils defaultColor]];
    [_payButton setFrame:CGRectMake(self.frame.size.width * .55, FRAME_HEIGHT/2 -15, self.frame.size.width * .22, 30)];
    [_payButton addTarget:self action:@selector(request) forControlEvents:UIControlEventTouchUpInside];
    
    titleString = [Utils defaultString:@"Pay" size:11 color:[UIColor whiteColor]];
    [_payButton.layer setCornerRadius:5];
    [_payButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _ignoreButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_ignoreButton setBackgroundColor:[UIColor darkGrayColor]];
    [_ignoreButton setFrame:CGRectMake(self.frame.size.width * .30, FRAME_HEIGHT/2 - 15, self.frame.size.width * .22, 30)];
    [_ignoreButton addTarget:self action:@selector(ignore) forControlEvents:UIControlEventTouchUpInside];
    
    titleString = [Utils defaultString:@"Ignore" size:11 color:[UIColor whiteColor]];
    [_ignoreButton.layer setCornerRadius:5];
    [_ignoreButton setAttributedTitle: titleString forState:UIControlStateNormal];
    [self addSubview:_ignoreButton];
    
    return self;
}

-(void) request {
    [Database updateTripMembershipsWithIDs:[NSArray arrayWithObject:_memberID] status:@1 withBlock:^(NSArray *data) {
        NSDictionary *updated = [data firstObject];
        if (updated.count != 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Confirm Request" message:[NSString stringWithFormat: @"Would you like to request $%.2f", [[updated objectForKey:@"amount"]floatValue]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Already Completed" message:[NSString stringWithFormat:@"Someone has already completed this request."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            dispatch_async(dispatch_get_main_queue(),^{ [alert show];});
        }
    }];
}

-(void) ignore {
    [Database updateTripMembershipWithID:_memberID status:@2 withBlock:^(NSDictionary *data) {
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
}

@end
