//
//  SearchViewTableViewCell.m
//  Pump
//
//  Created by Clay Jones on 9/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SearchViewTableViewCell.h"
#import "Utils.h"

#define CELL_HEIGHT 50

@implementation SearchViewTableViewCell

@synthesize user = _user;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)setUser:(NSDictionary *)user{
    _user = user;
    self.textLabel.attributedText = [Utils defaultString:[_user objectForKey:@"display_name"] size:16 color:[UIColor darkGrayColor]] ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(self.frame.size.width * .1 - 20, CELL_HEIGHT * .5 - 20,40,40);
}
@end
