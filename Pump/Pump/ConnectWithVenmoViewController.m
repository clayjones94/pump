//
//  ConnectWithVenmoViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ConnectWithVenmoViewController.h"
#import "Utils.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import <Parse/Parse.h>
#import "PhoneViewController.h"
#import "FindCarViewController.h"

@interface ConnectWithVenmoViewController ()

@end

@implementation ConnectWithVenmoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    [Utils addDefaultGradientToView:self.view];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pig"]];
    [image setFrame:CGRectMake(self.view.frame.size.width/2 - image.frame.size.width/2, self.view.frame.size.height/2 - image.frame.size.height/2, 150, 158)];
    [self.view addSubview:image];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"Connect with Venmo" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .21 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    [descriptionLabel setAttributedText:[Utils defaultString:@"In order to exchange gas money\rbetween you and your friends, you\rmust connect to a Venmo account." size:14 color:[UIColor whiteColor]]];
    [descriptionLabel setNumberOfLines:3];
    //[descriptionLabel sizeThatFits:CGSizeMake(titleLabel.frame.size.width, 300)];
    [descriptionLabel sizeToFit];
    [descriptionLabel setFrame:CGRectMake(width/2 - descriptionLabel.frame.size.width/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height)];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    UIButton *connectVenmo = [UIButton buttonWithType: UIButtonTypeCustom];
    [connectVenmo setBackgroundColor:[UIColor whiteColor]];
    [connectVenmo.layer setCornerRadius:10];
    [connectVenmo setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .90 -15, width * .8, 30)];
    [connectVenmo addTarget:self action:@selector(connectToVenmo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectVenmo];
    
    NSAttributedString *titleString = [Utils defaultString:@"CONNECT" size:14 color:[Utils defaultColor]];
    [connectVenmo setAttributedTitle: titleString forState:UIControlStateNormal];
    
    
    UIButton *skipButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [skipButton setBackgroundColor:[UIColor clearColor]];
    [skipButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height * .95 -20, 180, 40)];
    [skipButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    titleString = [Utils defaultString:@"Don't have Venmo" size:14 color:[UIColor whiteColor]];
    [skipButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) skip {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)connectToVenmo {
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
