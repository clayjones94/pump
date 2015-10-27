//
//  PassengerTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PassengerTableViewCell.h"
#import "Utils.h"

#define CELL_HEIGHT 50

@implementation PassengerTableViewCell

@synthesize passenger = _passenger;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)setPassenger:(NSDictionary *)passenger {
    _passenger = passenger;
    self.textLabel.attributedText = [Utils defaultString:_passenger[@"username"] size:12 color:[UIColor whiteColor]] ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(self.frame.size.width * .1 - 20, CELL_HEIGHT * .5 - 20,30,30);
}

@end
