//
//  BorrowCarTableViewCell.m
//  en
//
//  Created by Clay Jones on 10/26/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "BorrowCarTableViewCell.h"
#import "Utils.h"

#define CELL_HEIGHT 70

@implementation BorrowCarTableViewCell {
    UILabel *_mpgLabel;
}

@synthesize user = _user;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
//    self.backgroundColor = [UIColor clearColor];
//    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width - 20, CELL_HEIGHT - 10)];
//    backgroundView.backgroundColor = [UIColor whiteColor];
//    [self addSubview:backgroundView];
//    [self sendSubviewToBack:backgroundView];
    
    _mpgLabel = [[UILabel alloc] init];
    [self addSubview:_mpgLabel];
    
    return self;
}

-(void)setUser:(PFUser *)user{
    _user = user;
    self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@", _user[@"first_name_cased"], _user[@"last_name_cased"]] size:16 color:[UIColor darkGrayColor]] ;
    self.detailTextLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@ %@", _user[@"car_make"], _user[@"car_model"], _user[@"car_year"]] size:10 color:[UIColor darkGrayColor]];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString: [Utils defaultString:[NSString stringWithFormat:@"%.1f", [_user[@"mpg"] floatValue]] size:14 color:[UIColor darkGrayColor]]];
    [title appendAttributedString:[Utils defaultString:@"mpg" size:10 color:[UIColor darkGrayColor]]];
    _mpgLabel.attributedText = title;
    [_mpgLabel sizeToFit];
    [_mpgLabel setFrame:CGRectMake(self.frame.size.width * .95 - _mpgLabel.frame.size.width, self.frame.size.height * .5 - _mpgLabel.frame.size.height * .5, _mpgLabel.frame.size.width, _mpgLabel.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //self.imageView.frame = CGRectMake(self.frame.size.width * .1 - 20, CELL_HEIGHT * .5 - 20,35,35);
    //[self.textLabel setFrame:CGRectMake(50, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

@end
