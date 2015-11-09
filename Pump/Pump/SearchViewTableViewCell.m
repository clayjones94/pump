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
@synthesize contact = _contact;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)setUser:(PFUser *)user{
    _user = user;
    self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@", _user[@"first_name_cased"], _user[@"last_name_cased"]] size:16 color:[UIColor darkGrayColor]] ;
    self.detailTextLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@", _user[@"phone"]] size:10 color:[UIColor darkGrayColor]] ;
}

-(void) setContact:(CNContact *)contact{
    _contact = contact;
    self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@ %@", contact.givenName,contact.familyName] size:16 color:[UIColor darkGrayColor]] ;
    if (contact.phoneNumbers.firstObject.value.stringValue) {
        self.detailTextLabel.attributedText = [Utils defaultString:contact.phoneNumbers.firstObject.value.stringValue size:10 color:[UIColor darkGrayColor]] ;
    }
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
