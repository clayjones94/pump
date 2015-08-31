//
//  SearchUserView.m
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SearchUserView.h"

@implementation SearchUserView {
    UITableView *_tableview;
}

@synthesize tokenField = _tokenField;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
    _tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    _tokenField.delegate = self;
    _tokenField.dataSource = self;
    [_tokenField setPlaceholderText:@"Choose a friends car..."];
    [_tokenField setToLabelText:@""];
    [_tokenField.layer setBorderWidth:.5];
    [_tokenField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height - 40)];
    [self addSubview:_tableview];
    [self addSubview:_tokenField];
    
    return self;
}

@end
