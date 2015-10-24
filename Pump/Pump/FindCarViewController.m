//
//  FindCarViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "FindCarViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "CarYearViewController.h"

@interface FindCarViewController ()

@end

@implementation FindCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"Find your car" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .21 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    [descriptionLabel setAttributedText:[Utils defaultString:@"Tell us what car you have and\rwe will be able to find your\rcars mileage." size:14 color:[UIColor whiteColor]]];
    [descriptionLabel setNumberOfLines:3];
    [descriptionLabel sizeToFit];
    [descriptionLabel setFrame:CGRectMake(width/2 - descriptionLabel.frame.size.width/2, titleLabel.frame.origin.y + titleLabel.frame.size.height + 4, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height)];
    [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:descriptionLabel];
    
    UIButton *findCarButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [findCarButton setBackgroundColor:[UIColor whiteColor]];
    [findCarButton.layer setCornerRadius:10];
    [findCarButton setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .90 -15, width * .8, 30)];
    [findCarButton addTarget:self action:@selector(findCar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:findCarButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"FIND MY CAR" size:14 color:[Utils defaultColor]];
    [findCarButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    
    UIButton *skipButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [skipButton setBackgroundColor:[UIColor clearColor]];
    [skipButton setFrame:CGRectMake(self.view.frame.size.width/2 - 90 , self.view.frame.size.height * .95 -20, 180, 40)];
    [skipButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipButton];
    
    titleString = [Utils defaultString:@"I don't own a car" size:14 color:[UIColor whiteColor]];
    [skipButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) findCar {
    CarYearViewController *vc = [CarYearViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) skip {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end