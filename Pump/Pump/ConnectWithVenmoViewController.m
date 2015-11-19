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
//    [PFUser currentUser][@"using_venmo"] = [NSNumber numberWithBool:NO];
//    [[PFUser currentUser] saveInBackground];
//    if (![PFUser currentUser][@"phone"]) {
//        PhoneViewController *vc = [PhoneViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
//    } else {
//[       PFUser currentUser][@"using_car"] = [NSNumber numberWithBool: NO];
//        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }];
//    }
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
//                                                         [PFUser currentUser][@"using_venmo"] = [NSNumber numberWithBool:YES];
//                                                         [PFUser currentUser][@"using_car"] = [NSNumber numberWithBool: NO];
//                                                         if ([Venmo sharedInstance].session.user.primaryPhone && ![PFUser currentUser][@"phone"]) {
//                                                             [PFUser currentUser][@"phone"] = [Venmo sharedInstance].session.user.primaryPhone;
//                                                             [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                                                                 if (succeeded) {
//                                                                     // The object has been saved.
//                                                                     if (![PFUser currentUser][@"phone"]) {
//                                                                         PhoneViewController *vc = [PhoneViewController new];
//                                                                         [self.navigationController pushViewController:vc animated:YES];
//                                                                     } else{
//                                                                         [[PFUser currentUser] saveInBackground];
//                                                                         [self dismissViewControllerAnimated:YES completion:nil];
//                                                                     }
//                                                                 } else {
//                                                                    
//                                                                 }
//                                                             }];
//                                                         } else {
//                                                             [[PFUser currentUser] saveInBackground];
//                                                             if (![PFUser currentUser][@"phone"]) {
//                                                                 PhoneViewController *vc = [PhoneViewController new];
//                                                                 [self.navigationController pushViewController:vc animated:YES];
//                                                             }
//                                                             else {
//                                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//                                                             }
//                                                         }
                                                         
                                                     } else {

                                                         dispatch_async(dispatch_get_main_queue(), ^{
                    
                                                         });
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
