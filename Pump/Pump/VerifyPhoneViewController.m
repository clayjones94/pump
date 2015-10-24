//
//  VerifyPhoneViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "VerifyPhoneViewController.h"
#import "VerifyPhoneViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "DecimalKeypad.h"
#import "FindCarViewController.h"

#define TEXT_FIELD_WIDTH 50

@interface VerifyPhoneViewController ()

@end

@implementation VerifyPhoneViewController {
    NSMutableArray *_fields;
    NSString *_inputCode;
    UIButton *_verifyPhoneButton;
}
@synthesize code = _code;
@synthesize phoneNumber = _phoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"Enter your code" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .11 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    
    _inputCode = @"";
    _fields = [NSMutableArray new];
    for (int i = 1; i < 5; i++) {
        UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(width * i/5 - TEXT_FIELD_WIDTH/2, height * .30 - 10, TEXT_FIELD_WIDTH, TEXT_FIELD_WIDTH)];
        [field setBackgroundColor:[UIColor clearColor]];
        [field setTextColor:[UIColor whiteColor]];
        [field setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:26]];
        [field setTextAlignment:NSTextAlignmentCenter];
        [field setUserInteractionEnabled:NO];
        [field.layer setBorderColor:[UIColor whiteColor].CGColor];
        [field.layer setBorderWidth:1];
        [field.layer setCornerRadius:TEXT_FIELD_WIDTH/2];
        [field setText:@" "];
        [self.view addSubview:field];
        [_fields addObject:field];
    }
    
    DecimalKeypad *keyboard = [[DecimalKeypad alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height * .95 -30) - height/2, width, height/2)];
    [keyboard setBackgroundColor:[UIColor clearColor]];
    [keyboard setTextColor:[UIColor whiteColor]];
    [keyboard setUseDecimal:NO];
    keyboard.delegate = self;
    [self.view addSubview:keyboard];
    
    _verifyPhoneButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_verifyPhoneButton.layer setCornerRadius:10];
    [_verifyPhoneButton setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .95 -15, width * .8, 30)];
    [_verifyPhoneButton addTarget:self action:@selector(verifyPhone) forControlEvents:UIControlEventTouchUpInside];
    [_verifyPhoneButton setUserInteractionEnabled:NO];
    [_verifyPhoneButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_verifyPhoneButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"VERIFY" size:14 color:[Utils defaultColor]];
    [_verifyPhoneButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void)keypad:(DecimalKeypad *)keypad didPressNumberValue:(NSString *)number {
    if (_inputCode.length > 3) {
        [_verifyPhoneButton setUserInteractionEnabled:NO];
        [_verifyPhoneButton setBackgroundColor:[UIColor lightGrayColor]];
        return;
    }
    _inputCode = [_inputCode stringByAppendingString:number];
    [self setInputView];
    if (_inputCode.length == 4) {
        [_verifyPhoneButton setUserInteractionEnabled:YES];
        [_verifyPhoneButton setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)didBackspaceKeypad:(DecimalKeypad *)keypad {
    if (_inputCode.length == 0) return;
    [_verifyPhoneButton setUserInteractionEnabled:NO];
    [_verifyPhoneButton setBackgroundColor:[UIColor lightGrayColor]];
    _inputCode = [_inputCode substringToIndex:_inputCode.length - 1];
    [self setInputView];
}

-(void) setInputView {
    for (NSUInteger i = 0; i < 4; i++) {
        if (i < _inputCode.length) {
            NSString *number = [NSString stringWithFormat:@"%c", [_inputCode characterAtIndex:i]];
            UILabel *label =[_fields objectAtIndex:i];
            [label setText:number];
        } else {
            UILabel *label =[_fields objectAtIndex:i];
            [label setText:@" "];
        }
    }
}

-(void) verifyPhone {
    if ([_inputCode isEqualToString:_code]) {
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"phone"] = _phoneNumber;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                FindCarViewController *vc = [FindCarViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                // There was a problem, check error.description
            }
        }];
        [[[UIAlertView alloc] initWithTitle:@"Success"
                                    message:@"Your phone number was successfully verified."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    } else if(_inputCode.length < 4) {

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong code"
                                    message:@"Looks like the code that you provided did not match our verification code."
                                   delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Send Again", nil];
        alert.delegate = self;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int randomID = arc4random() % 9000 + 1000;
        __block NSString *code = [NSString stringWithFormat:@"%d", randomID];
        _code = code;
        _inputCode = @"";
        [self setInputView];
        [PFCloud callFunctionInBackground:@"verifyPhoneNumber"
                           withParameters:@{ @"number" : _phoneNumber,
                                             @"verification_code" : code
                                             }
                                    block:^(id object, NSError *error) {
                                        [[[UIAlertView alloc] initWithTitle:@"Code sent!"
                                                                    message:@"Your SMS verification code has been sent!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil] show];
                                        _code = code;
                                        
                                    }];
    }
}

@end
