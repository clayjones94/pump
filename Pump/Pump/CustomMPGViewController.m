//
//  CustomMPGViewController.m
//  Pump
//
//  Created by Clay Jones on 10/23/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "CustomMPGViewController.h"
#import "Utils.h"
#import "DecimalKeypad.h"
#import <Parse/Parse.h>
#import "TripManager.h"

@interface CustomMPGViewController ()

@end

@implementation CustomMPGViewController {
    UITextField *_mpgField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    //    [cancelButton setFrame:CGRectMake(10, 30 , 25, 25)];
    //    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:cancelButton];
    //    //
    //    //    [self.view clipsToBounds];
    //    //    [self.view addSubview:topBar];
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    [Utils addDefaultGradientToView:self.view];
    
    _mpgField = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width - 100)/2, self.view.frame.size.height * 1/4 - 40, self.view.frame.size.width - 100, 80)];
    [_mpgField setAttributedPlaceholder:[Utils defaultString:@"0" size:45 color:[UIColor whiteColor]]];
    [_mpgField setBackgroundColor:[Utils defaultLightColor]];
    [_mpgField.layer setCornerRadius:10];
    //[_mpgField setPlaceholder:@"0"];
    [_mpgField setTextAlignment:NSTextAlignmentCenter];
    //[mpgField setAttributedText:[Utils defaultString:@"" size:30 color:[UIColor blackColor]]];
    [_mpgField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:45]];
    [_mpgField setTextColor:[UIColor whiteColor]];
    [self.view addSubview:_mpgField];
    [_mpgField setUserInteractionEnabled:NO];
    //[_mpgField setKeyboardType:UIKeyboardTypeDecimalPad];
    //[_mpgField becomeFirstResponder];
    
    UILabel *title = [[UILabel alloc] init];
    [title setAttributedText: [Utils defaultString:@"Enter gas mileage" size:20 color:[UIColor whiteColor]]];
    [title sizeToFit];
    [title setFrame:CGRectMake(self.view.frame.size.width/2 - title.frame.size.width/2, _mpgField.frame.origin.y - title.frame.size.height - 3, title.frame.size.width, title.frame.size.height)];
    [self.view addSubview:title];
    
    DecimalKeypad *keypad = [[DecimalKeypad alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2 - 60, self.view.frame.size.width, self.view.frame.size.height/2)];
    [keypad setBackgroundColor:[UIColor clearColor]];
    [keypad setTextColor:[UIColor whiteColor]];
    keypad.delegate = self;
    keypad.tag = 0;
    [self.view addSubview:keypad];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [doneButton setBackgroundColor:[Utils defaultLightColor]];
    [doneButton setFrame:CGRectMake(0, keypad.frame.origin.y + keypad.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (keypad.frame.origin.y + keypad.frame.size.height))];
    [doneButton addTarget:self action:@selector(selectMPG) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"ENTER" size:24 color:[UIColor whiteColor]];
    //[doneButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    //[doneButton.layer setBorderWidth:1];
    [doneButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) selectMPG {
    NSNumber *mpg = [NSNumber numberWithDouble: [_mpgField.text doubleValue]];
    if ([mpg doubleValue] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter MPG" message:@"The mileage you have entered is not valid" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (![TripManager sharedManager].car) {
        [[NSUserDefaults standardUserDefaults] setObject:mpg forKey:@"mpg"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [TripManager sharedManager].mpg = mpg;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)keypad:(DecimalKeypad *)keypad didPressNumberValue:(NSString *)number {
    if (keypad.tag == 0) {
        _mpgField.text = [_mpgField.text stringByAppendingString:number];
    }
}

-(void)didBackspaceKeypad:(DecimalKeypad *)keypad {
    if (keypad.tag == 0) {
        if ([_mpgField.text length] > 0) {
            _mpgField.text = [_mpgField.text substringToIndex:[_mpgField.text length] - 1];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
