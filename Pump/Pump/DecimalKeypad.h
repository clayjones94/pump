//
//  DecimalKeypad.h
//  Pump
//
//  Created by Clay Jones on 10/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DecimalKeypad;

@protocol DecimalKeypadDelegate <NSObject>
@optional
- (void) keypad: (DecimalKeypad *)keypad didPressNumberValue: (NSString *)number;
- (void) didBackspaceKeypad: (DecimalKeypad *)keypad;
@end

@interface DecimalKeypad : UIView

@property id <DecimalKeypadDelegate> delegate;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) BOOL useDecimal;


@end
