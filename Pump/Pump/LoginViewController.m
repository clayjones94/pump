//
//  LoginViewController.m
//  Pump
//
//  Created by Clay Jones on 9/4/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "LoginViewController.h"
#import "Utils.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "UserManager.h"
#import "Database.h"
#import "RegisterViewController.h"
#import "SignInViewController.h"


@implementation LoginViewController {
    UIButton *signInButton;
    UIButton *registerButton;
    UIActivityIndicatorView *_indicator;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils addDefaultGradientToView:self.view];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_title"]];
    [image setFrame:CGRectMake(self.view.frame.size.width/2 - image.frame.size.width/2, self.view.frame.size.height/2 - image.frame.size.height/2, 245, 160)];
    [self.view addSubview:image];
    
    signInButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [signInButton setBackgroundColor:[UIColor clearColor]];
    [signInButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height * .8 - 20, 180, 40)];
    [signInButton addTarget:self action:@selector(signInUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"SIGN IN" size:14 color:[UIColor whiteColor]];
    [signInButton.layer setCornerRadius:3];
    [signInButton.layer setBorderWidth:1];
    [signInButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [signInButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    registerButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [registerButton setBackgroundColor:[UIColor clearColor]];
    [registerButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height * .9 -20, 180, 40)];
    [registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    
    titleString = [Utils defaultString:@"REGISTER" size:14 color:[UIColor whiteColor]];
    [registerButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setFrame:CGRectMake(self.view.frame.size.width/2 - 15, self.view.frame.size.height/2 - 15, 30, 30)];
    [self.view addSubview:_indicator];
    [_indicator setHidden:YES];
}

-(void) registerUser {
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) signInUser {
    SignInViewController *vc = [[SignInViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
