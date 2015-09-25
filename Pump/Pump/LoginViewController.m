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

@implementation LoginViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Login Background"]];
    [background setFrame:self.view.frame];
    [self.view addSubview:background];
    
    UIButton *venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setImage:[UIImage imageNamed:@"Venmo Logo"] forState:UIControlStateNormal];
    [venmoButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 15)];
    [venmoButton setBackgroundColor:[UIColor whiteColor]];
    [venmoButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height/2 - 24, 180, 40)];
    [venmoButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:venmoButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Login with Venmo" size:14 color:[UIColor grayColor]];
    [venmoButton.layer setCornerRadius:10];
    [venmoButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) login {
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments,
                                                 VENPermissionAccessProfile,
                                                 VENPermissionAccessBalance,
                                                 VENPermissionAccessEmail,
                                                 VENPermissionAccessPhone,
                                                 VENPermissionAccessFriends] withCompletionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

@end
