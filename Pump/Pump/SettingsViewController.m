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

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitle:@"Settings"];
    UIButton *venmoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [venmoButton setBackgroundColor:[UIColor redColor]];
    [venmoButton setFrame:CGRectMake(self.view.frame.size.width/2 - 75 , 85, 150, 30)];
    [venmoButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:venmoButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"Logout" size:14 color:[UIColor whiteColor]];
    [venmoButton.layer setCornerRadius:5];
    [venmoButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
}

-(void) logout {
    [[Venmo sharedInstance] logout];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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
