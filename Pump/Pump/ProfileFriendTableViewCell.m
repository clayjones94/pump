//
//  ProfileFriendTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ProfileFriendTableViewCell.h"
#import "Utils.h"

#define FRAME_HEIGHT 60
#define DESCRIPTION_FONT_SIZE 8

@implementation ProfileFriendTableViewCell {
    UILabel *_nameLabel;
    UILabel *_amountOwedLabel;
    UILabel *_numberOfRidesLabel;
    UIImageView *_imageView;
}

@synthesize friendName = _friendName;
@synthesize amountOwed = _amountOwed;
@synthesize numberOfRides = _numberOfRides;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * .2, 15, 0, 0)];
    [self addSubview:_nameLabel];
    
    _amountOwedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 0, 0)];
    [self addSubview:_amountOwedLabel];
    
    _numberOfRidesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width * .6, 15, 0, 0)];
    [self addSubview:_numberOfRidesLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (FRAME_HEIGHT - 40)/2, 40, 40)];
    [_imageView setImage: [UIImage imageNamed:@"profile_pic_default"]];
    [self addSubview:_imageView];
    
    return self;
}

- (void)setFriendName:(NSString *)friendName {
    _friendName = friendName;
    [_nameLabel setAttributedText:[Utils defaultString:_friendName size:18 color:[UIColor blackColor]]];
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(self.frame.size.width * .2, (FRAME_HEIGHT - _nameLabel.frame.size.height)/2, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
}

- (void)setAmountOwed:(NSNumber *)amountOwed {
    _amountOwed = amountOwed;
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:_friendName size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
    
    [description appendAttributedString:[Utils defaultString:@" owes you " size:DESCRIPTION_FONT_SIZE color:[UIColor blackColor]]];
    [description appendAttributedString:[Utils defaultString:[NSString stringWithFormat:@"$%.0f.", [amountOwed doubleValue]] size:DESCRIPTION_FONT_SIZE color:[Utils defaultColor]]];
    [_nameLabel setAttributedText:description];
    [_nameLabel sizeToFit];
    [_nameLabel setFrame:CGRectMake(self.frame.size.width * .2, (FRAME_HEIGHT - _nameLabel.frame.size.height)/2, _nameLabel.frame.size.width, _nameLabel.frame.size.height)];
}

-(void) setNumberOfRides:(NSNumber *)numberOfRides {
    _numberOfRides = numberOfRides;
    [_numberOfRidesLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%@ rides", numberOfRides] size:12 color:[UIColor lightGrayColor]]];
    [_numberOfRidesLabel sizeToFit];
    [_numberOfRidesLabel setFrame:CGRectMake(self.frame.size.width * .77, (FRAME_HEIGHT - _numberOfRidesLabel.frame.size.height)/2, _numberOfRidesLabel.frame.size.width, _numberOfRidesLabel.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
