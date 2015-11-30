//
//  PhoneViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "PhoneViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "DecimalKeypad.h"
#import "VerifyPhoneViewController.h"

#define TEXT_FIELD_WIDTH 200

@interface PhoneViewController ()

@end

@implementation PhoneViewController {
    UITextField *_phoneField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    [Utils addDefaultGradientToView:self.view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"We need your phone" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .11 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    [descriptionLabel setAttributedText:[Utils defaultString:@"This way we can connect you with\ryour friends and make ride sharing\ra seemless process." size:14 color:[UIColor whiteColor]]];
    [descriptionLabel setNumberOfLines:3];
    //[descriptionLabel sizeThatFits:CGSizeMake(titleLabel.frame.size.width, 300)];
    [descriptionLabel sizeToFit];
    [descriptionLabel setFrame:CGRectMake(width/2 - descriptionLabel.frame.size.width/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height-20)];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(width/2 - TEXT_FIELD_WIDTH/2, height * .30 - 10, TEXT_FIELD_WIDTH, 20)];
    [_phoneField setBackgroundColor:[UIColor clearColor]];
    [_phoneField setAttributedPlaceholder:[Utils defaultString:@"" size:22 color:[UIColor whiteColor]]];
    [_phoneField setTextAlignment:NSTextAlignmentLeft];
    [_phoneField setTextColor:[UIColor whiteColor]];
    [_phoneField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:26]];
    [_phoneField setTextAlignment:NSTextAlignmentCenter];
    [_phoneField setUserInteractionEnabled:NO];
    [_phoneField setDelegate:self];
    [self.view addSubview:_phoneField];
    
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(_phoneField.frame.origin.x, _phoneField.frame.origin.y + _phoneField.frame.size.height + 3, _phoneField.frame.size.width, 1)];
    [underline setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:underline];
    
    DecimalKeypad *keyboard = [[DecimalKeypad alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height * .95 -30) - height/2, width, height/2)];
    [keyboard setBackgroundColor:[UIColor clearColor]];
    [keyboard setTextColor:[UIColor whiteColor]];
    [keyboard setUseDecimal:NO];
    keyboard.delegate = self;
    [self.view addSubview:keyboard];
    
    UIButton *verifyPhone = [UIButton buttonWithType: UIButtonTypeCustom];
    [verifyPhone setBackgroundColor:[UIColor whiteColor]];
    [verifyPhone.layer setCornerRadius:10];
    [verifyPhone setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .95 -15, width * .8, 30)];
    [verifyPhone addTarget:self action:@selector(verifyPhone) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:verifyPhone];
    
    NSAttributedString *titleString = [Utils defaultString:@"CONNECT" size:14 color:[Utils defaultColor]];
    [verifyPhone setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void)keypad:(DecimalKeypad *)keypad didPressNumberValue:(NSString *)number {
    if (_phoneField.text.length > 11) return;
    if (_phoneField.text.length == 3 || _phoneField.text.length == 7) {
        _phoneField.text = [_phoneField.text stringByAppendingString:@"-"];
    }
    _phoneField.text = [_phoneField.text stringByAppendingString:number];
}

-(void)didBackspaceKeypad:(DecimalKeypad *)keypad {
    if (_phoneField.text.length == 0) return;
    if (_phoneField.text.length == 5 || _phoneField.text.length == 9) {
        _phoneField.text = [_phoneField.text substringToIndex:_phoneField.text.length - 2];
    } else {
        _phoneField.text = [_phoneField.text substringToIndex:_phoneField.text.length - 1];
    }
}

-(void) verifyPhone {
    if (_phoneField.text.length != 12) {
        return;
    }
    __block NSString *phoneNumber = _phoneField.text;
    int randomID = arc4random() % 9000 + 1000;
    __block NSString *code = [NSString stringWithFormat:@"%d", randomID];
    [PFCloud callFunctionInBackground:@"verifyPhoneNumber"
                       withParameters:@{ @"number" : _phoneField.text,
                                         @"verification_code" : code
                                       }
                                block:^(id object, NSError *error) {
                                    VerifyPhoneViewController *vc = [[VerifyPhoneViewController alloc] init];
                                    [vc setCode:code];
                                    [vc setPhoneNumber:phoneNumber];
                                    [self.navigationController pushViewController:vc animated:YES];
                                    
                                }];
}

@end
