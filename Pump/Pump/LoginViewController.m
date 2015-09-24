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
    
    UIButton *venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setBackgroundColor:[UIColor lightGrayColor]];
    [venmoButton setFrame:CGRectMake(self.view.frame.size.width/2 - 75 , self.view.frame.size.height/2 - 15, 200, 50)];
    [venmoButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:venmoButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Venmo" size:25 color:[UIColor whiteColor]];
    [venmoButton.layer setCornerRadius:5];
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
