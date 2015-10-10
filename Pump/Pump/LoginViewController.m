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


@implementation LoginViewController {
    UIButton *venmoButton;
    UIButton *proceedButton;
    UIActivityIndicatorView *_indicator;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login Background"]];
    [background setFrame:self.view.frame];
    [self.view addSubview:background];
    
    venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setImage:[UIImage imageNamed:@"Venmo Logo"] forState:UIControlStateNormal];
    [venmoButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 15)];
    [venmoButton setBackgroundColor:[UIColor whiteColor]];
    [venmoButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height/2 - 24, 180, 40)];
    [venmoButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:venmoButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Login with Venmo" size:14 color:[UIColor grayColor]];
    [venmoButton.layer setCornerRadius:10];
    [venmoButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    proceedButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [proceedButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 15)];
    [proceedButton setBackgroundColor:[UIColor clearColor]];
    [proceedButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height/2 + 22, 180, 40)];
    [proceedButton addTarget:self action:@selector(continueWithout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:proceedButton];
    
    titleString = [Utils defaultString:@"Continue Without Venmo..." size:14 color:[UIColor whiteColor]];
    [proceedButton.layer setCornerRadius:10];
    [proceedButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setFrame:CGRectMake(self.view.frame.size.width/2 - 15, self.view.frame.size.height/2 - 15, 30, 30)];
    [self.view addSubview:_indicator];
    [_indicator setHidden:YES];
}

-(void) continueWithout {
    [UserManager sharedManager].notUsingVenmo = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) login {
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments,
                                                 VENPermissionAccessProfile,
                                                 VENPermissionAccessBalance,
                                                 VENPermissionAccessEmail,
                                                 VENPermissionAccessPhone,
                                                 VENPermissionAccessFriends] withCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [venmoButton setUserInteractionEnabled:NO];
                [proceedButton setUserInteractionEnabled:NO];
                [_indicator setHidden:NO];
                [_indicator startAnimating];
            });
            [Database authUserWithVenmoWithBlock:^(BOOL success) {
                if (success) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [UserManager sharedManager].notUsingVenmo = NO;
                } else {
                    [[Venmo sharedInstance] logout];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [venmoButton setUserInteractionEnabled:YES];
                    [proceedButton setUserInteractionEnabled:YES];
                    [_indicator setHidden:YES];
                    [_indicator stopAnimating];
                });
            }];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

@end
