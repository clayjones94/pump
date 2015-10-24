//
//  SignInViewController.m
//  Pump
//
//  Created by Clay Jones on 10/21/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SignInViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "ConnectWithVenmoViewController.h"

#define TEXT_FIELD_WIDTH 200
#define MAX_CHARACTER_LENGTH 50

@interface SignInViewController ()

@end

@implementation SignInViewController {
    UITextField *_usernameField;
    UITextField *_passwordField;
    UIScrollView *_scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login Background"]];
    [background setFrame:self.view.frame];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.5)];
    [_scrollView setScrollEnabled:NO];
    [_scrollView setBackgroundColor:[Utils defaultColor]];
    [self.view addSubview:_scrollView];
    
    CGFloat height = self.view.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(width/2 - TEXT_FIELD_WIDTH/2, height * .42 - 10, TEXT_FIELD_WIDTH, 20)];
    [_usernameField setBackgroundColor:[UIColor clearColor]];
    [_usernameField setAttributedPlaceholder:[Utils defaultString:@"USERNAME" size:14 color:[UIColor whiteColor]]];
    [_usernameField setTextAlignment:NSTextAlignmentLeft];
    [_usernameField setTextColor:[UIColor whiteColor]];
    [_usernameField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:14]];
    [_usernameField setDelegate:self];
    [_scrollView addSubview:_usernameField];
    
    UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(_usernameField.frame.origin.x, _usernameField.frame.origin.y + _usernameField.frame.size.height + 3, _usernameField.frame.size.width, 1)];
    [underline setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:underline];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(width/2 - TEXT_FIELD_WIDTH/2, height * .49 - 10, TEXT_FIELD_WIDTH, 20)];
    [_passwordField setBackgroundColor:[UIColor clearColor]];
    [_passwordField setAttributedPlaceholder:[Utils defaultString:@"PASSWORD" size:14 color:[UIColor whiteColor]]];
    [_passwordField setTextAlignment:NSTextAlignmentLeft];
    [_passwordField setTextColor:[UIColor whiteColor]];
    [_passwordField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:14]];
    [_passwordField setDelegate:self];
    [_scrollView addSubview:_passwordField];
    
    underline = [[UIView alloc] initWithFrame:CGRectMake(_passwordField.frame.origin.x, _passwordField.frame.origin.y + _passwordField.frame.size.height + 3, _passwordField.frame.size.width, 1)];
    [underline setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:underline];
    
    UIButton *registerButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [registerButton setBackgroundColor:[UIColor clearColor]];
    [registerButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height * .56 -10, 180, 20)];
    [registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:registerButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"SIGN IN" size:14 color:[UIColor whiteColor]];
    [registerButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [_scrollView addGestureRecognizer:tap];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(30, 30, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancelButton];
}

-(void) cancel {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITextField class]] || [touch.view isKindOfClass:[UIButton class]]) return YES;
    return NO;
}

-(void)dismissKeyboard {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [textField setPlaceholder:@""];
    //    [_scrollView scrollRectToVisible:textField.frame animated:YES];
    //    [_scrollView scrollRectToVisible:CGRectMake(0, textField.frame.origin.y + self.view.frame.size.height * 1/4, textField.frame.size.width, textField.frame.size.width) animated:YES];
    [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - self.view.frame.size.height * 1/4) animated:YES];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        NSString *placeholder;
        if ([textField isEqual:_usernameField]) {
            placeholder = @"USERNAME";
        } else if ([textField isEqual:_passwordField]) {
            placeholder = @"PASSWORD";
        } else {
            placeholder = @"REPEAT PASSWORD";
        }
        [textField setAttributedPlaceholder:[Utils defaultString:placeholder size:14 color:[UIColor whiteColor]]];
    }
}

-(void) registerUser {
    if (_passwordField.text.length >= 7) {
        NSString *username = _usernameField.text;
        NSString *password = _passwordField.text;
        
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (user) {   // Hooray! Let them use the app now.
                ConnectWithVenmoViewController *vc = [ConnectWithVenmoViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
            }
        }];
    } else if (_passwordField.text.length < 7){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Too Short" message:@"Your password must be at least 7 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Mismatch" message:@"It seems that the two passwords you provided were not identical." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
