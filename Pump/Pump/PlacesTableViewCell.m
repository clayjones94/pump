//
//  PlacesTableViewCell.m
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "PlacesTableViewCell.h"
#import "Utils.h"

#define CELL_HEIGHT 50

@implementation PlacesTableViewCell

@synthesize place = _place;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)setPlace:(GMSAutocompletePrediction *)place{
    _place = place;
    NSRange range = [_place.attributedFullText.string rangeOfString:@", "];
    if (range.location < 40) {
        self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@", [_place.attributedFullText.string substringToIndex:range.location]] size:16 color:[UIColor darkGrayColor]] ;
        self.detailTextLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@", [_place.attributedFullText.string substringFromIndex:range.location + range.length]] size:10 color:[UIColor darkGrayColor]] ;
    } else {
        self.textLabel.attributedText = [Utils defaultString:[NSString stringWithFormat:@"%@", _place.attributedFullText.string] size:16 color:[UIColor darkGrayColor]] ;
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
