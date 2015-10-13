//
//  DecimalKeypad.m
//  Pump
//
//  Created by Clay Jones on 10/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "DecimalKeypad.h"
#import "Utils.h"

@implementation DecimalKeypad {
    NSMutableArray *_buttons;
    NSArray *icons;
    CGFloat margin;
}

@synthesize backgroundColor = _backgroundColor;
@synthesize textColor = _textColor;
@synthesize useDecimal = _useDecimal;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    icons = @[@"1", @"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@".",@"0"];
    _buttons = [NSMutableArray new];
    _useDecimal = YES;
    margin = .5;
    for (int i = 1; i <= 11; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setAttributedTitle:[Utils defaultString:icons[i-1] size:26 color:[UIColor blackColor]] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(((i-1)%3) * frame.size.width/3 + margin, ((i-1)/3) * frame.size.height/4 + margin, frame.size.width/3 - margin*2, frame.size.height/4 - margin*2)];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        if (i <= 9) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width * .15, button.frame.size.height * .9, button.frame.size.width * .7, 1)];
            [lineView setBackgroundColor:[UIColor whiteColor]];
            lineView.alpha = .8;
            [button addSubview:lineView];
        }
        [_buttons addObject:button];
        [self addSubview:button];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(((12-1)%3) * frame.size.width/3 + margin, ((12-1)/3) * frame.size.height/4 + margin, frame.size.width/3 - margin*2, frame.size.height/4 - margin*2)];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 12;
    [_buttons addObject:button];
    [self addSubview:button];
    return  self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    for (UIButton *button in _buttons) {
        [button setBackgroundColor:backgroundColor];
    }
}

-(void)setUseDecimal:(BOOL)useDecimal {
    _useDecimal = useDecimal;
    [[_buttons objectAtIndex:9] setUserInteractionEnabled:useDecimal];
}

-(void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (UIButton *button in _buttons) {
        if (button.tag != 12) {
            [button setAttributedTitle:[Utils defaultString:button.titleLabel.attributedText.string size:26 color:textColor] forState:UIControlStateNormal];
        }
    }
}

-(void) clickButton: (UIButton *) sender {
    if (sender.tag < 12) {
        [self.delegate keypad:self didPressNumberValue:sender.titleLabel.text];
    } else {
        [self.delegate didBackspaceKeypad:self];
    }
}

@end
