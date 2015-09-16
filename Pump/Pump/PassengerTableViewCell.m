//
//  PassengerTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PassengerTableViewCell.h"

#define CELL_HEIGHT 40

@implementation PassengerTableViewCell

@synthesize passenger = _passenger;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)setPassenger:(NSDictionary *)passenger {
    _passenger = passenger;
    self.textLabel.text = [_passenger objectForKey:@"display_name"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
