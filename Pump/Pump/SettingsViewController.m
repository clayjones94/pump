//
//  SettingsViewController.m
//  Pump
//
//  Created by Clay Jones on 9/24/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SettingsViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "Utils.h"
#import "UserManager.h"
#import "Constants.h"
#import "Database.h"
#import "TripManager.h"
#import "CustomMPGViewController.h"

@interface SettingsViewController ()
@end

@implementation SettingsViewController {
    UIButton *venmoButton;
    UILabel *mpgLabel;
    UIButton *mpgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.navigationItem setTitle:@"Settings"];
    
    UIView *venmoView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * .05 , 100 - 20, self.view.frame.size.width * .9, 40)];
    [venmoView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:venmoView];
    
    UIImageView *venmoImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"venmo_logo_blue"]];
    [venmoImage sizeToFit];
    [venmoView addSubview:venmoImage];
    [venmoImage setFrame:CGRectMake(venmoView.frame.size.width * .05 , venmoView.frame.size.height/2 - venmoImage.frame.size.height/2, venmoImage.frame.size.width, venmoImage.frame.size.height)];
    
    venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setBackgroundColor:[UIColor grayColor]];
    [venmoButton setFrame:CGRectMake(venmoView.frame.size.width * .7 , venmoView.frame.size.height/2 - 12.5, venmoView.frame.size.width * .25, 25)];
    [venmoButton addTarget:self action:@selector(venmo) forControlEvents:UIControlEventTouchUpInside];
    [venmoView addSubview:venmoButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Connect" size:14 color:[UIColor whiteColor]];
    if ([Venmo sharedInstance].isSessionValid) {
        titleString = [Utils defaultString:@"Connected" size:14 color:[UIColor whiteColor]];
        [venmoButton setBackgroundColor:[Utils greenColor]];
    }
    [venmoButton.layer setCornerRadius:5];
    [venmoButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    mpgView = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * .05 , 150 - 20, self.view.frame.size.width * .9, 40)];
    [mpgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:mpgView];
    
    mpgLabel = [[UILabel alloc] init];
    [mpgLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%.1f mpg", [[[NSUserDefaults standardUserDefaults]objectForKey:@"mpg"] floatValue]] size:14 color:[UIColor darkGrayColor]]];
    [mpgLabel sizeToFit];
    [mpgView addSubview:mpgLabel];
    [mpgLabel setFrame:CGRectMake(mpgView.frame.size.width * .95 -  mpgLabel.frame.size.width, mpgView.frame.size.height/2 - mpgLabel.frame.size.height/2, mpgLabel.frame.size.width, mpgLabel.frame.size.height)];
    
    UILabel *mpgDescrLabel = [[UILabel alloc] init];
    [mpgDescrLabel setAttributedText:[Utils defaultString:@"Mileage" size:14 color:[UIColor darkGrayColor]]];
    [mpgDescrLabel sizeToFit];
    [mpgView addSubview:mpgDescrLabel];
    [mpgDescrLabel setFrame:CGRectMake(mpgView.frame.size.width * .05 , mpgView.frame.size.height/2 - mpgDescrLabel.frame.size.height/2, mpgDescrLabel.frame.size.width, mpgDescrLabel.frame.size.height)];
    
    [mpgView addTarget:self action:@selector(changeMPG) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
}

-(void) changeMPG {
    [[TripManager sharedManager] setCar:nil];
    CustomMPGViewController *vc = [CustomMPGViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [mpgLabel setAttributedText:[Utils defaultString:[NSString stringWithFormat:@"%.1f mpg", [[[NSUserDefaults standardUserDefaults] objectForKey:@"mpg"] floatValue]] size:14 color:[UIColor darkGrayColor]]];
    [mpgLabel sizeToFit];
    [mpgLabel setFrame:CGRectMake(mpgView.frame.size.width * .95 -  mpgLabel.frame.size.width, mpgView.frame.size.height/2 - mpgLabel.frame.size.height/2, mpgLabel.frame.size.width, mpgLabel.frame.size.height)];
}

-(void) venmo {
    if ([Venmo sharedInstance].isSessionValid) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Disconnect Venmo" message:@"Are you sure you would like to disconnect your Venmo accout." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[Venmo sharedInstance] logout];
            [venmoButton setBackgroundColor:[UIColor grayColor]];
            [venmoButton setAttributedTitle:[Utils defaultString:@"Connect" size:14 color:[UIColor whiteColor]] forState:UIControlStateNormal];
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:logoutAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[UserManager sharedManager] loginWithBlock:^(BOOL loggedIn) {
            if (!loggedIn) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"An error occured while connecting to Venmo." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                [venmoButton setBackgroundColor:[Utils greenColor]];
                [venmoButton setAttributedTitle:[Utils defaultString:@"Connected" size:14 color:[UIColor whiteColor]] forState:UIControlStateNormal];
            }
        }];
    }
}

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
